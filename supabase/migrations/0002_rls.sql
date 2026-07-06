-- Loot — RLS policies migration 0002
-- Public read for catalog; own-rows for customer data; admin claim for catalog writes.

-- helper: admin check from JWT custom claim
create function public.is_admin() returns boolean
language sql stable as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin', false)
$$;

-- ── Catalog: public read, admin write ──────────────────────────────────────
do $$
declare t text;
begin
  foreach t in array array['brands','categories','age_groups','products',
                           'product_categories','product_age_groups',
                           'product_images','product_variants','promotions']
  loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy %I_admin_all on %I for all using (public.is_admin()) with check (public.is_admin())', t, t);
  end loop;
end $$;

create policy brands_public_read on brands for select using (true);
create policy categories_public_read on categories for select using (true);
create policy age_groups_public_read on age_groups for select using (true);
create policy products_public_read on products for select using (status = 'active' or public.is_admin());
create policy product_categories_public_read on product_categories for select using (true);
create policy product_age_groups_public_read on product_age_groups for select using (true);
create policy product_images_public_read on product_images for select using (true);
create policy product_variants_public_read on product_variants for select using (true);
create policy promotions_public_read on promotions for select using (is_active);

-- ── Profiles / addresses ───────────────────────────────────────────────────
alter table profiles enable row level security;
create policy profiles_own on profiles for all
  using (id = auth.uid()) with check (id = auth.uid());

alter table addresses enable row level security;
create policy addresses_own on addresses for all
  using (profile_id = auth.uid()) with check (profile_id = auth.uid());

-- ── Carts: own rows (guest carts handled via edge functions w/ anon_key) ───
alter table carts enable row level security;
create policy carts_own on carts for all
  using (profile_id = auth.uid()) with check (profile_id = auth.uid());

alter table cart_items enable row level security;
create policy cart_items_own on cart_items for all
  using (exists (select 1 from carts c where c.id = cart_id and c.profile_id = auth.uid()))
  with check (exists (select 1 from carts c where c.id = cart_id and c.profile_id = auth.uid()));

-- ── Orders: read own; inserts only via place_order function (security definer)
alter table orders enable row level security;
create policy orders_own_read on orders for select using (profile_id = auth.uid());
create policy orders_admin_all on orders for all using (public.is_admin()) with check (public.is_admin());

alter table order_items enable row level security;
create policy order_items_own_read on order_items for select
  using (exists (select 1 from orders o where o.id = order_id and (o.profile_id = auth.uid() or public.is_admin())));

alter table order_events enable row level security;
create policy order_events_own_read on order_events for select
  using (exists (select 1 from orders o where o.id = order_id and (o.profile_id = auth.uid() or public.is_admin())));
create policy order_events_admin_write on order_events for insert with check (public.is_admin());

-- ── Wishlists / reviews ────────────────────────────────────────────────────
alter table wishlists enable row level security;
create policy wishlists_own on wishlists for all
  using (profile_id = auth.uid()) with check (profile_id = auth.uid());

alter table reviews enable row level security;
create policy reviews_public_read on reviews for select using (status = 'approved' or profile_id = auth.uid() or public.is_admin());
create policy reviews_own_insert on reviews for insert with check (profile_id = auth.uid());
create policy reviews_admin_moderate on reviews for update using (public.is_admin()) with check (public.is_admin());

-- Guest order lookup (order_no + phone) is served by an edge function using the
-- service role, never by direct table access, so no anonymous policy exists here.
