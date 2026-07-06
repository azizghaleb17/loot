# Loot (getloot.co) — Phase 1 Design Spec

> Canonical spec: this file mirrors the user-provided architecture & delivery plan
> (`toystore-flutter-plan.md`). Decisions below are approved and locked.

**Brand:** Loot — domain `getloot.co` (owned) · **Market:** Kuwait (KWD) · **Team:** solo developer · **Budget:** minimal, free tiers · **Targets:** Flutter web demo → App Store → Google Play, single codebase.

Two Kuwait-specific facts drive several decisions: (1) KWD has **three decimal places** (1 KWD = 1,000 fils) — all money is stored as integer fils, never floats; (2) **KNET dominates Kuwaiti online payments**, and **cash on delivery is a mainstream expectation**, so both are first-class in checkout. Kuwait has no VAT, but order totals model a tax line.

## Locked decisions (summary)

| Concern | Decision |
|---|---|
| Architecture | Feature-first, pragmatic 3-layer Clean (presentation/domain/data per feature) |
| State management | Riverpod v2+ (AsyncNotifier, provider composition, keepAlive caching) |
| Navigation | GoRouter, `usePathUrlStrategy()`, slug-based URLs |
| Local persistence | hive_ce (web-safe via IndexedDB); **sqflite banned** (no web) |
| Backend | Supabase (Postgres, Auth, Storage, Edge Functions, RLS); FCM for push (Phase 2) |
| Payments | MyFatoorah hosted page (KNET first, COD second, card); sandbox in demo |
| Money | Integer fils (KWD, 3 dp), single `Money` value type |
| Admin | Supabase Studio (P1) → Appsmith (P2) |
| Hosting | Cloudflare Pages, SPA `_redirects`, branch previews |
| Renderer | CanvasKit (default build) |
| Fonts | Baloo Bhaijaan 2 (display, AR+EN) + IBM Plex Sans Arabic (body) |
| Icons | Phosphor (rounded) |
| i18n | flutter_localizations + ARB (en, ar), RTL-first widgets only |
| CI/CD | GitHub Actions (analyze/test/web build/deploy) |

## Route table

`/` home · `/age/:ageSlug` · `/c/:categorySlug` · `/b/:brandSlug` · `/p/:productSlug` ·
`/search?q=&age=&brand=&min=&max=&sort=` · `/cart` · `/checkout` · `/checkout/result` ·
`/orders` · `/orders/:id` · `/account` · `/wishlist` · `/signin`

## Design language: "Toybox"

Playful browse surfaces / trusted transactional surfaces via a `SurfaceMode`. Palette:
ink `#1E2A4A`, coral `#E8503A`, teal `#0E8A8A`, sunshine `#FFC53D` (never text),
sky `#EAF4FB`, cream `#FFF8F0`, success `#1F8A4C`, error `#C6362B`, info `#2D6FD2`,
6 pastel age hues paired with ink. Color carried by fills/illustration; text is ink (AA).
Type scale 32/28/22/18/16/14/12, body line-height 1.5, +5-10% for Arabic.
Spacing 4/8/12/16/24/32/48. Radii: 24 playful cards, 16 product cards, 12 buttons,
8 chips/checkout inputs. Touch targets ≥48dp. Checkout clamps at 560px; content at 1200px.
Grids via `SliverGridDelegateWithMaxCrossAxisExtent(240)`. Bottom nav <600, top nav ≥1024.

## Data model (Postgres, all money integer fils)

brands, categories (tree), age_groups (6: 0-12m…12y+), products (+ar fields, slug unique,
status enum), product_categories, product_age_groups, product_images, product_variants
(sku, price_fils, compare_at_price_fils, stock_qty, is_default; every product ≥1 variant),
profiles, addresses (Kuwaiti shape: governorate/area/block/street/building/floor/apt),
carts (+anon_key for guests), cart_items, orders (status + payment enums, fils totals,
address jsonb snapshot), order_items (denormalized snapshots), order_events, wishlists,
reviews (P3), promotions. Stock decrement only inside a `place_order` Postgres function
(transactional, row-locked). RLS: own-rows for carts/orders/addresses/wishlists;
public-read products/categories; admin claim for catalog writes.

## Phase 1 scope (contract)

**In:** scaffold (theme, tokens, l10n EN+AR, router, Riverpod); Supabase schema + RLS +
`place_order` SQL committed; seed catalog 40–60 products; home + age hub + category +
search/filter + product detail; guest cart (Hive) + promo code; guest checkout with
Kuwaiti address form; MyFatoorah sandbox hosted-page (KNET test) + COD; order confirmation
+ guest order lookup; email/Google sign-in + cart merge; wishlist; responsive desktop;
branded splash; Cloudflare Pages + previews; Supabase keep-alive cron.
**Out:** reviews, push, Apple Sign-In (UI slot only), Apple Pay, real payment credentials,
transactional emails, admin beyond Studio, analytics.

## Session constraint (this build)

No external credentials are available in this session (GitHub remote, Supabase project,
Cloudflare account, MyFatoorah token, Google OAuth). Per the spec's agent instructions,
credentials must never be invented or hardcoded. Therefore this build:

1. Implements everything credential-free end-to-end, with data access behind repository
   interfaces backed by a **local demo data source** (bundled seed catalog, Hive cart,
   locally-recorded demo orders) selected by a `BackendMode.demo` flag.
2. Authors and commits the Supabase SQL migrations, RLS policies, `place_order` function,
   Edge Function sources (`create-payment`, `payment-webhook`), keep-alive cron workflow,
   and `env.example.json` — ready to apply the moment the user supplies credentials.
3. Ends with the exact list of credentials to request from the user (spec §"accounts &
   credentials", items 1–7) and where each goes.

Swapping `BackendMode.demo` → `BackendMode.supabase` changes only the data layer;
presentation and domain are unaffected. This is the seam the spec's architecture demands.
