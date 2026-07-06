-- Loot — schema migration 0001
-- All money columns are integer fils (KWD, 3 dp). Never floats.

create extension if not exists pgcrypto;

-- ── Catalog ────────────────────────────────────────────────────────────────

create table brands (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  name_ar     text not null,
  slug        text not null unique,
  logo_url    text,
  created_at  timestamptz not null default now()
);

create table categories (
  id          uuid primary key default gen_random_uuid(),
  parent_id   uuid references categories(id) on delete set null,
  name        text not null,
  name_ar     text not null,
  slug        text not null unique,
  icon        text,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);

create table age_groups (
  id          uuid primary key default gen_random_uuid(),
  slug        text not null unique,      -- 0-12m, 1-2, 3-5, 6-8, 9-12, 12-plus
  label       text not null,
  label_ar    text not null,
  min_months  int not null,
  max_months  int,                        -- null = open-ended
  sort_order  int not null default 0
);

create type product_status as enum ('draft', 'active', 'archived');

create table products (
  id             uuid primary key default gen_random_uuid(),
  brand_id       uuid references brands(id),
  name           text not null,
  name_ar        text not null,
  slug           text not null unique,    -- immutable after publish
  description    text not null default '',
  description_ar text not null default '',
  safety_notes   text,
  status         product_status not null default 'draft',
  rating_avg     numeric(3,2) not null default 0,
  rating_count   int not null default 0,
  created_at     timestamptz not null default now()
);

create table product_categories (
  product_id  uuid not null references products(id) on delete cascade,
  category_id uuid not null references categories(id) on delete cascade,
  primary key (product_id, category_id)
);

create table product_age_groups (
  product_id   uuid not null references products(id) on delete cascade,
  age_group_id uuid not null references age_groups(id) on delete cascade,
  primary key (product_id, age_group_id)
);

create table product_images (
  id          uuid primary key default gen_random_uuid(),
  product_id  uuid not null references products(id) on delete cascade,
  url         text not null,
  alt         text,
  alt_ar      text,
  sort_order  int not null default 0
);

create table product_variants (
  id                    uuid primary key default gen_random_uuid(),
  product_id            uuid not null references products(id) on delete cascade,
  sku                   text not null unique,
  name                  text not null default '',
  name_ar               text not null default '',
  price_fils            int not null check (price_fils >= 0),
  compare_at_price_fils int check (compare_at_price_fils > price_fils),
  stock_qty             int not null default 0 check (stock_qty >= 0),
  is_default            boolean not null default false,
  created_at            timestamptz not null default now()
);
create index on product_variants (product_id);

-- Full-text search over EN + AR names/descriptions
alter table products add column fts tsvector
  generated always as (
    setweight(to_tsvector('simple', coalesce(name, '') || ' ' || coalesce(name_ar, '')), 'A') ||
    setweight(to_tsvector('simple', coalesce(description, '') || ' ' || coalesce(description_ar, '')), 'B')
  ) stored;
create index products_fts_idx on products using gin (fts);

-- ── Customers ──────────────────────────────────────────────────────────────

create table profiles (
  id               uuid primary key references auth.users(id) on delete cascade,
  full_name        text,
  phone            text,
  preferred_locale text not null default 'en',
  created_at       timestamptz not null default now()
);

create table addresses (
  id          uuid primary key default gen_random_uuid(),
  profile_id  uuid not null references profiles(id) on delete cascade,
  label       text,
  governorate text not null,   -- Kuwaiti shape: no ZIP codes
  area        text not null,
  block       text not null,
  street      text not null,
  building    text not null,
  floor       text,
  apartment   text,
  directions  text,
  phone       text not null,
  is_default  boolean not null default false,
  created_at  timestamptz not null default now()
);
create index on addresses (profile_id);

-- ── Cart ───────────────────────────────────────────────────────────────────

create table carts (
  id         uuid primary key default gen_random_uuid(),
  profile_id uuid references profiles(id) on delete cascade,
  anon_key   text,             -- guest carts
  updated_at timestamptz not null default now(),
  check (profile_id is not null or anon_key is not null)
);
create unique index carts_profile_uniq on carts (profile_id) where profile_id is not null;
create unique index carts_anon_uniq on carts (anon_key) where anon_key is not null;

create table cart_items (
  id         uuid primary key default gen_random_uuid(),
  cart_id    uuid not null references carts(id) on delete cascade,
  variant_id uuid not null references product_variants(id) on delete cascade,
  qty        int not null check (qty > 0),
  unique (cart_id, variant_id)
);

-- ── Orders ─────────────────────────────────────────────────────────────────

create type order_status as enum (
  'pending_payment', 'paid', 'cod_confirmed', 'processing',
  'shipped', 'delivered', 'cancelled', 'refunded'
);
create type payment_method as enum ('knet', 'card', 'apple_pay', 'cod');

create sequence order_no_seq start 1001;

create table orders (
  id               uuid primary key default gen_random_uuid(),
  order_no         text not null unique default ('LOOT-' || nextval('order_no_seq')),
  profile_id       uuid references profiles(id),        -- null = guest
  email            text not null,
  phone            text not null,
  status           order_status not null default 'pending_payment',
  payment_method   payment_method not null,
  payment_ref      text unique,                          -- idempotency key for webhooks
  subtotal_fils    int not null check (subtotal_fils >= 0),
  shipping_fils    int not null default 0 check (shipping_fils >= 0),
  discount_fils    int not null default 0 check (discount_fils >= 0),
  tax_fils         int not null default 0 check (tax_fils >= 0),   -- Kuwait: 0 today, schema-ready
  total_fils       int not null check (total_fils >= 0),
  shipping_address jsonb not null,                       -- snapshot, not FK
  placed_at        timestamptz not null default now(),
  paid_at          timestamptz
);
create index on orders (profile_id);
create index on orders (order_no, phone);

create table order_items (
  id              uuid primary key default gen_random_uuid(),
  order_id        uuid not null references orders(id) on delete cascade,
  variant_id      uuid references product_variants(id),
  product_name    text not null,      -- denormalized snapshots, immune to edits
  product_name_ar text not null,
  image_url       text,
  unit_price_fils int not null check (unit_price_fils >= 0),
  qty             int not null check (qty > 0)
);
create index on order_items (order_id);

create table order_events (
  id         uuid primary key default gen_random_uuid(),
  order_id   uuid not null references orders(id) on delete cascade,
  status     order_status not null,
  note       text,
  created_at timestamptz not null default now()
);
create index on order_events (order_id);

-- ── Wishlist / reviews / promotions ───────────────────────────────────────

create table wishlists (
  profile_id uuid not null references profiles(id) on delete cascade,
  product_id uuid not null references products(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (profile_id, product_id)
);

create type review_status as enum ('pending', 'approved', 'rejected');

create table reviews (
  id         uuid primary key default gen_random_uuid(),
  product_id uuid not null references products(id) on delete cascade,
  profile_id uuid not null references profiles(id) on delete cascade,
  order_id   uuid references orders(id),   -- non-null = verified purchase
  rating     int not null check (rating between 1 and 5),
  title      text,
  body       text,
  status     review_status not null default 'pending',
  created_at timestamptz not null default now()
);

create type promo_type as enum ('percent', 'fixed', 'free_shipping');

create table promotions (
  id             uuid primary key default gen_random_uuid(),
  code           text not null unique,
  type           promo_type not null,
  value          int not null,             -- percent 0-100, or fils for fixed
  min_order_fils int not null default 0,
  starts_at      timestamptz,
  ends_at        timestamptz,
  max_uses       int,
  used_count     int not null default 0,
  is_active      boolean not null default true
);

-- auto-create profile row on signup
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name) values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
