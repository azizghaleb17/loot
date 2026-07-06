# Loot — getloot.co

Flutter e-commerce app for a Kuwaiti toy store. One codebase → web demo now,
App Store + Google Play in Phase 2.

- **Money:** KWD, 3 decimal places — everything is integer fils via the `Money` type. No floats, ever.
- **Languages:** English + Arabic (full RTL), switchable in Account.
- **Payments (design):** KNET-first via MyFatoorah hosted page + cash on delivery.
- **Backend:** Supabase (schema/RLS/`place_order` in `supabase/`); the demo runs credential-free on a local seed catalog behind the same repository interfaces (`BACKEND_MODE=demo`).

## Run

```sh
flutter pub get
flutter run -d chrome
```

## Test & build

```sh
flutter analyze
flutter test
flutter build web --release --dart-define=BACKEND_MODE=demo
```

## Demo walkthrough

Browse by age (the six pastel cards) → product page → add to cart → promo code
`LOOT10` → checkout as guest (Kuwaiti address form) → pay with sandbox KNET or
COD → order confirmation → track under Account → My orders, or "Find an order"
with the order number + phone.

## Structure

```
lib/
├── app/            # MaterialApp.router, GoRouter table, bootstrap
├── core/           # theme tokens, Money, l10n (ARB en/ar), shared widgets
├── features/       # catalog, search, cart, checkout, orders, wishlist, auth, account
│                   #   each: domain / data / presentation
└── gen/l10n/       # generated localizations (flutter gen-l10n)
supabase/           # migrations (schema, RLS, place_order), edge functions, ready to apply
.github/workflows/  # CI (analyze/test/RTL-lint/build/deploy) + Supabase keep-alive cron
docs/superpowers/   # design spec + implementation plan
```

## Connecting the real backend (when credentials exist)

1. Create a Supabase project; run `supabase/migrations/*.sql` in order.
2. Copy `env.example.json` → `env.dev.json`, fill URL + anon key.
3. Run with `--dart-define-from-file=env.dev.json --dart-define=BACKEND_MODE=supabase`.
4. Set `MYFATOORAH_*` secrets for the edge functions (`supabase secrets set`).
5. Add `SUPABASE_URL`/`SUPABASE_ANON_KEY`/`CLOUDFLARE_*` GitHub secrets — CI deploy and keep-alive activate automatically.
