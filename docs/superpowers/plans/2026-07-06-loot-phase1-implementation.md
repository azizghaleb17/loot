# Loot Phase 1 Web Demo — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A working Flutter-web e-commerce demo for Loot (Kuwait toy store) — browse → cart → guest checkout → order lookup — with all backend artifacts (Supabase SQL, Edge Functions, CI) authored and committed, running credential-free behind a demo data source.

**Architecture:** Feature-first, 3-layer (presentation/domain/data) per feature. Riverpod for state, GoRouter for slug URLs, Hive (hive_ce) for guest cart/wishlist/orders persistence. All data access behind repository interfaces; this session ships a `demo` backend (bundled seed catalog + local order placement); the `supabase` backend slots in later without touching presentation/domain.

**Tech Stack:** Flutter (stable), flutter_riverpod, go_router, hive_ce + hive_ce_flutter, google_fonts, flutter_localizations + intl (ARB en/ar), flutter_lints. No freezed/codegen in Phase-1 demo layer (introduced with Supabase DTOs later). No sqflite (banned — no web support).

## Global Constraints

- All money is `int` fils (KWD, 3 decimal places). Only `Money` formats currency. Never double.
- Only `EdgeInsetsDirectional` / `AlignmentDirectional` / `start|end` — never `left|right` paddings/alignments (RTL). CI greps for violations.
- Palette/typography/radii exactly per spec §3.1 (ink #1E2A4A, coral #E8503A, teal #0E8A8A, sunshine #FFC53D never as text color, sky #EAF4FB, cream #FFF8F0; Baloo Bhaijaan 2 display, IBM Plex Sans Arabic body; radii 24/16/12/8).
- Slug-based URLs per spec route table; `usePathUrlStrategy()`.
- No credentials invented or hardcoded. `env.example.json` committed; real `env.*.json` gitignored.
- Checkout content max width 560; global clamp 1200; grids `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 240)`.
- KNET listed first in payment methods, COD second, card third; Apple Pay slot disabled with "Phase 2" tag.
- Guest checkout requires only email + phone + Kuwaiti address (governorate/area/block/street/building, optional floor/apt/directions).

---

### Task 1: Repo + Flutter scaffold
**Files:** `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `README.md`, `web/index.html`, `web/_redirects`, `lib/main.dart`, `lib/app/app.dart`, `lib/app/bootstrap.dart`, `lib/core/config/env.dart`, `env.example.json`
- [ ] `flutter create` (web platform), org `co.getloot`, project `loot`
- [ ] Add deps: flutter_riverpod, go_router, hive_ce, hive_ce_flutter, google_fonts, intl, flutter_localizations; dev: flutter_lints
- [ ] `Env` reads `--dart-define` (SUPABASE_URL, SUPABASE_ANON_KEY, BACKEND_MODE default `demo`)
- [ ] `bootstrap()` initializes Hive, ProviderScope, path URL strategy
- [ ] Verify: `flutter analyze` clean, `flutter test` green (smoke test), commit

### Task 2: Core theme + Money
**Files:** `lib/core/theme/palette.dart`, `spacing.dart`, `radii.dart`, `typography.dart`, `app_theme.dart`, `surface_mode.dart`; `lib/core/utils/money.dart`; `test/core/utils/money_test.dart`, `test/core/theme/theme_test.dart`
**Interfaces:** `Money(int fils)` value type: `+ - * comparisons`, `Money.fromKwd(String)`, `format(Locale)` → "KD 7.500" / "د.ك 7.500" (Western numerals, tabular), `formatCompact`; `AppTheme.light(TextTheme arabicAware)`; `SurfaceMode {playful, trusted}` exposed via `SurfaceScaffold`.
- [ ] TDD Money: zero, add, multiply by qty, 3-dp formatting both locales, thousands separator, compare-at
- [ ] Theme tokens per Global Constraints; `ThemeData` M3 with custom ColorScheme
- [ ] Commit

### Task 3: l10n EN+AR
**Files:** `l10n.yaml`, `lib/core/l10n/arb/app_en.arb`, `app_ar.arb`, `lib/core/l10n/locale_provider.dart`; test for locale persistence
**Interfaces:** `context.l10n` extension; `localeProvider` (Riverpod `Notifier<Locale?>`, persisted in Hive box `settings`).
- [ ] All UI strings in ARB from day one (~120 keys); Arabic translations
- [ ] Commit

### Task 4: Router + AdaptiveScaffold
**Files:** `lib/app/router/routes.dart`, `app_router.dart`; `lib/core/widgets/adaptive_scaffold.dart`; stub screens per feature
**Interfaces:** route names as `RouteNames.*` constants; full spec URL map; `AdaptiveScaffold(currentTab, child)` — bottom nav <600 (Home/Search/Cart/Wishlist/Account with cart badge), top app bar with inline links ≥1024.
- [ ] ShellRoute hosts tabs; product/checkout push over shell
- [ ] Commit

### Task 5: Domain + data layer + seed catalog
**Files:** `lib/features/catalog/domain/{product,variant,category,brand,age_group}.dart`; `lib/features/catalog/data/{catalog_repository.dart,demo_catalog_repository.dart,seed_data.dart}`; `lib/features/catalog/presentation/providers.dart`; tests
**Interfaces:**
```dart
abstract interface class CatalogRepository {
  Future<List<AgeGroup>> ageGroups();
  Future<List<Category>> categories();
  Future<List<Brand>> brands();
  Future<Product?> productBySlug(String slug);
  Future<List<Product>> query(CatalogQuery q); // q: text, ageSlugs, categorySlug, brandSlugs, minFils, maxFils, inStockOnly, sort, section (newArrivals|bestSellers)
}
```
`Product` carries variants (each `priceFils`, `compareAtPriceFils?`, `stockQty`, `isDefault`), `emojiArt` + pastel seed for demo imagery, `nameAr/descriptionAr`, age slugs, category slugs, safety notes. Seed: 6 age groups, 10 categories, 12 brands, 48 products.
- [ ] TDD repository filtering/sorting/search
- [ ] `catalogRepositoryProvider` selects demo impl via `Env.backendMode`; keepAlive caching providers
- [ ] Commit

### Task 6: Browse UI (frontend-design pass first)
**Files:** `lib/core/widgets/{toy_button,product_card,age_card,price_text,rating_stars,section_header,empty_state,filter_chip_bar,qty_stepper,shimmer}.dart`; `features/catalog/presentation/{home_screen,age_hub_screen,category_screen,brand_screen}.dart`; `features/search/presentation/search_screen.dart`
- [ ] Home: search bar → age rail (6 illustrated pastel cards) → promo banner → New arrivals / Best sellers shelves → brand strip → category grid
- [ ] Age hub / category: curated header, filter chips, responsive grid; sort control
- [ ] Search: debounced, filter sheet (age multi, price range KWD, brand multi, in-stock), all state in query params (shareable URLs)
- [ ] Commit per screen

### Task 7: Product detail
**Files:** `features/catalog/presentation/product_screen.dart` (+ gallery, variant selector, accordion widgets)
- [ ] Gallery (swipe), brand link, rating, age chips, price + compare-at strikethrough, variant selector, qty stepper, sticky add-to-cart bar, accordion (description/safety/shipping), "More for this age" shelf, share (copy URL)
- [ ] Two-pane ≥1024. Commit

### Task 8: Cart
**Files:** `features/cart/domain/cart.dart`; `data/{cart_repository,hive_cart_repository}.dart`; `presentation/{cart_screen,providers}.dart`; `features/cart/domain/promo.dart`; tests
**Interfaces:** `CartNotifier` (`AsyncNotifier<Cart>`): `add(variantId, qty)`, `setQty`, `remove`, `applyPromo(code)`; `Cart.subtotal/shipping/discount/total` all `Money`. Demo promos: `LOOT10` (10%), `FREESHIP`. Flat shipping 2.000 KD, free ≥ 15.000 KD.
- [ ] TDD totals/promo math; swipe-to-remove with undo; trusted SurfaceMode. Commit

### Task 9: Checkout + orders
**Files:** `features/checkout/domain/{address,order}.dart`; `data/{order_repository,demo_order_repository}.dart`; `presentation/{checkout_screen,payment_step,address_step,contact_step,result_screen}.dart`; `features/orders/presentation/{orders_screen,order_detail_screen,order_lookup_screen}.dart`; tests
**Interfaces:** `OrderRepository.place(DraftOrder) → Order` (demo impl: validates stock, assigns `LOOT-1001+` order number, persists to Hive, simulates KNET redirect via in-app fake gateway page for sandbox realism; COD → `cod_confirmed`); `OrderRepository.byNumberAndPhone(no, phone)` for guest lookup; `order_events` timeline.
- [ ] 3 steps, one screen each, 560px clamp, Kuwaiti address form (6 governorates dropdown)
- [ ] KNET first, COD second, card third, Apple Pay disabled slot
- [ ] Result screen with order number + "create account to track" prompt. Commit

### Task 10: Wishlist + account + auth slots
**Files:** `features/wishlist/*` (Hive-backed), `features/account/presentation/account_screen.dart`, `features/auth/presentation/signin_screen.dart`
- [ ] Sign-in screen with Email / Google / Apple slots (Apple tagged Phase 2; Google/email disabled with "connect Supabase" note in demo mode), guest emphasized
- [ ] Account: language switch, orders link, addresses (Hive CRUD), wishlist tab. Commit

### Task 11: Backend + CI artifacts (no live services)
**Files:** `supabase/migrations/0001_schema.sql`, `0002_rls.sql`, `0003_place_order.sql`, `supabase/functions/create-payment/index.ts`, `supabase/functions/payment-webhook/index.ts`, `supabase/seed/seed.sql`, `.github/workflows/ci.yml`, `.github/workflows/keepalive.yml`, `env.example.json`
- [ ] Full spec §2.2 schema; RLS per spec; `place_order` row-locks variants, validates stock, inserts order+items+event, decrements — one transaction
- [ ] CI: analyze + test + RTL-lint grep + `flutter build web --release` + Cloudflare Pages deploy step (guarded on secrets)
- [ ] Commit

### Task 12: Web polish + verification
**Files:** `web/index.html` (branded splash, title/meta/OG), `web/_redirects`
- [ ] Branded HTML/CSS splash (logo + progress), meta/OG tags
- [ ] `flutter analyze` clean; `flutter test` green; `flutter build web --release` succeeds; run app, exercise browse→cart→checkout→lookup; screenshots
- [ ] Code review pass (code-review skill); fix findings; final commit

### Handoff: credentials to request from user (end of session report)
GitHub repo · Supabase project URL + anon key + service_role + DB string · Cloudflare Account ID + API token + DNS for getloot.co · Google OAuth client · MyFatoorah sandbox token.
