import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/price_text.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../core/widgets/sticker_tile.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../wishlist/presentation/wishlist_providers.dart';
import '../domain/models.dart';
import 'providers.dart';

/// Product detail (`/p/slug`): gallery, brand link, rating, age chips,
/// price + compare-at, variant selector, qty stepper, sticky add-to-cart,
/// accordion, "More for this age" shelf, share. Two-pane ≥1024 (spec §3.2-3.3).
class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.productSlug});

  final String productSlug;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  String? _selectedSku;
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final productAsync = ref.watch(productBySlugProvider(widget.productSlug));

    return productAsync.when(
      loading: () => const SafeArea(
        child: ContentClamp(child: ProductPageSkeleton()),
      ),
      error: (e, _) => ErrorView(
          onRetry: () =>
              ref.invalidate(productBySlugProvider(widget.productSlug))),
      data: (product) {
        if (product == null) {
          return EmptyState(
            emoji: '🧸',
            title: l10n.noResults,
            hint: l10n.noResultsHint,
            actionLabel: l10n.startShopping,
            onAction: () => context.go('/'),
          );
        }
        final variant =
            product.variantBySku(_selectedSku ?? '') ?? product.defaultVariant;
        final width = MediaQuery.sizeOf(context).width;
        final twoPane = Layout.isDesktop(width);

        final gallery = StickerTile(
          emoji: product.emoji,
          tile: product.tile,
          size: 96,
          borderRadius: Corners.playfulRadius,
        );
        final buyBox = _BuyBox(
          product: product,
          variant: variant,
          qty: _qty,
          onVariant: (sku) => setState(() => _selectedSku = sku),
          onQty: (q) => setState(() => _qty = q),
        );

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsetsDirectional.all(Gap.lg),
                  children: [
                    ContentClamp(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (twoPane)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: gallery),
                                const SizedBox(width: Gap.xxl),
                                Expanded(flex: 5, child: buyBox),
                              ],
                            )
                          else ...[
                            gallery,
                            const SizedBox(height: Gap.lg),
                            buyBox,
                          ],
                          const SizedBox(height: Gap.xxl),
                          _Accordion(product: product),
                          const SizedBox(height: Gap.xxl),
                          if (product.ageSlugs.isNotEmpty)
                            _MoreForAge(
                                ageSlug: product.ageSlugs.first,
                                excludeSlug: product.slug),
                          const SizedBox(height: 96),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Sticky add-to-cart bar (trusted action, always reachable).
              if (!twoPane)
                _StickyBar(product: product, variant: variant, qty: _qty),
            ],
          ),
        );
      },
    );
  }
}

class _BuyBox extends ConsumerWidget {
  const _BuyBox({
    required this.product,
    required this.variant,
    required this.qty,
    required this.onVariant,
    required this.onQty,
  });

  final Product product;
  final Variant variant;
  final int qty;
  final ValueChanged<String> onVariant;
  final ValueChanged<int> onQty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isAr = context.isArabic;
    final wishlisted = ref.watch(wishlistProvider).contains(product.slug);
    final ages = ref.watch(ageGroupsProvider).valueOrNull ?? [];
    final brands = ref.watch(brandsProvider).valueOrNull ?? [];
    final brand =
        brands.where((b) => b.slug == product.brandSlug).firstOrNull;
    final wide = Layout.isDesktop(MediaQuery.sizeOf(context).width);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (brand != null)
          InkWell(
            onTap: () => context.push('/b/${brand.slug}'),
            child: Text(
              isAr ? brand.nameAr : brand.name,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppPalette.teal),
            ),
          ),
        const SizedBox(height: Gap.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(isAr ? product.nameAr : product.name,
                  style: Theme.of(context).textTheme.displayMedium),
            ),
            IconButton(
              tooltip: l10n.navWishlist,
              onPressed: () =>
                  ref.read(wishlistProvider.notifier).toggle(product.slug),
              icon: Icon(
                wishlisted
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: wishlisted ? AppPalette.coral : AppPalette.inkMuted,
              ),
            ),
            IconButton(
              tooltip: l10n.share,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final copied = l10n.linkCopied;
                await Clipboard.setData(ClipboardData(
                    text: 'https://getloot.co/p/${product.slug}'));
                messenger.showSnackBar(SnackBar(content: Text(copied)));
              },
              icon: const Icon(Icons.share_outlined, color: AppPalette.inkMuted),
            ),
          ],
        ),
        if (product.ratingCount > 0)
          RatingStars(rating: product.ratingAvg, count: product.ratingCount),
        const SizedBox(height: Gap.md),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final slug in product.ageSlugs)
              ActionChip(
                avatar: Text(
                  ages.where((a) => a.slug == slug).firstOrNull?.emoji ?? '🧒',
                  style: const TextStyle(fontSize: 14),
                ),
                label: Text(
                  ages
                          .where((a) => a.slug == slug)
                          .map((a) => isAr ? a.labelAr : a.label)
                          .firstOrNull ??
                      slug,
                ),
                onPressed: () => context.push('/age/$slug'),
              ),
          ],
        ),
        const SizedBox(height: Gap.lg),
        PriceText(
          price: Money(variant.priceFils),
          compareAt: variant.compareAtPriceFils == null
              ? null
              : Money(variant.compareAtPriceFils!),
          style: Theme.of(context).textTheme.headlineMedium,
          emphasized: true,
        ),
        const SizedBox(height: Gap.lg),
        if (product.variants.length > 1) ...[
          Text(l10n.chooseOption,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final v in product.variants)
                ChoiceChip(
                  label: Text(isAr ? v.nameAr : v.name),
                  selected: v.sku == variant.sku,
                  onSelected:
                      v.inStock ? (_) => onVariant(v.sku) : null,
                ),
            ],
          ),
          const SizedBox(height: Gap.lg),
        ],
        Row(
          children: [
            Text(l10n.quantity, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: Gap.md),
            QtyStepper(qty: qty, onChanged: onQty, max: variant.stockQty),
          ],
        ),
        if (wide) ...[
          const SizedBox(height: Gap.xl),
          _AddToCartButton(product: product, variant: variant, qty: qty),
        ],
      ],
    );
  }
}

class _AddToCartButton extends ConsumerWidget {
  const _AddToCartButton({
    required this.product,
    required this.variant,
    required this.qty,
  });

  final Product product;
  final Variant variant;
  final int qty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: !variant.inStock
            ? null
            : () {
                ref
                    .read(cartProvider.notifier)
                    .add(product.slug, variant.sku, qty: qty);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.addedToCart),
                    action: SnackBarAction(
                      label: l10n.viewCart,
                      textColor: AppPalette.sunshine,
                      onPressed: () => context.push('/cart'),
                    ),
                  ),
                );
              },
        icon: const Icon(Icons.shopping_bag_outlined),
        label: Text(variant.inStock ? l10n.addToCart : l10n.outOfStock),
      ),
    );
  }
}

class _StickyBar extends ConsumerWidget {
  const _StickyBar({
    required this.product,
    required this.variant,
    required this.qty,
  });

  final Product product;
  final Variant variant;
  final int qty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsetsDirectional.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppPalette.white,
        border: const Border(top: BorderSide(color: AppPalette.hairline)),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          PriceText(
            price: Money(variant.priceFils * qty),
            style: Theme.of(context).textTheme.titleLarge,
            emphasized: true,
          ),
          const SizedBox(width: Gap.lg),
          Expanded(
              child:
                  _AddToCartButton(product: product, variant: variant, qty: qty)),
        ],
      ),
    );
  }
}

class _Accordion extends StatelessWidget {
  const _Accordion({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = context.isArabic;
    return Column(
      children: [
        _AccordionTile(
          title: l10n.description,
          body: isAr ? product.descriptionAr : product.description,
          initiallyExpanded: true,
        ),
        if (product.safetyNotes != null)
          _AccordionTile(title: l10n.safetyNotes, body: product.safetyNotes!),
        _AccordionTile(
            title: l10n.shippingReturns, body: l10n.shippingReturnsBody),
      ],
    );
  }
}

class _AccordionTile extends StatelessWidget {
  const _AccordionTile({
    required this.title,
    required this.body,
    this.initiallyExpanded = false,
  });

  final String title;
  final String body;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: Gap.sm),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: Corners.cardRadius,
        border: Border.all(color: AppPalette.hairline),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          initiallyExpanded: initiallyExpanded,
          iconColor: AppPalette.teal,
          childrenPadding: const EdgeInsetsDirectional.fromSTEB(
              Gap.lg, 0, Gap.lg, Gap.lg),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child:
                  Text(body, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreForAge extends ConsumerWidget {
  const _MoreForAge({required this.ageSlug, required this.excludeSlug});

  final String ageSlug;
  final String excludeSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results =
        ref.watch(catalogQueryProvider(CatalogQuery(ageSlugs: {ageSlug})));
    return results.maybeWhen(
      data: (items) {
        final others =
            items.where((p) => p.slug != excludeSlug).take(8).toList();
        if (others.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: context.l10n.moreForAge,
              onSeeAll: () => context.push('/age/$ageSlug'),
            ),
            SizedBox(
              height: 340,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: others.length,
                separatorBuilder: (_, _) => const SizedBox(width: Gap.lg),
                itemBuilder: (context, i) =>
                    SizedBox(width: 220, child: ProductCard(product: others[i])),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
