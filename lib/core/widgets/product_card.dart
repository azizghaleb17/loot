import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/catalog/domain/models.dart';
import '../../features/catalog/presentation/providers.dart';
import '../../features/wishlist/presentation/wishlist_providers.dart';
import '../l10n/l10n.dart';
import '../theme/palette.dart';
import '../theme/tokens.dart';
import '../utils/money.dart';
import 'common.dart';
import 'price_text.dart';
import 'sticker_tile.dart';

/// Product card: image tile, badges, brand, name, rating, price, wishlist
/// heart. Hover lift on web (spec §3.3).
class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final l10n = context.l10n;
    final isAr = context.isArabic;
    final wishlisted = ref.watch(wishlistProvider).contains(p.slug);
    final variant = p.defaultVariant;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: Corners.cardRadius,
          boxShadow: [
            BoxShadow(
              color: AppPalette.ink.withValues(alpha: _hovered ? 0.10 : 0.04),
              blurRadius: _hovered ? 18 : 10,
              offset: Offset(0, _hovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: Corners.cardRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/p/${p.slug}'),
            child: Semantics(
              button: true,
              label: '${isAr ? p.nameAr : p.name}, ${Money(variant.priceFils).format(isAr ? 'ar' : 'en')}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.all(Gap.sm),
                        child: StickerTile(emoji: p.emoji, tile: p.tile),
                      ),
                      PositionedDirectional(
                        top: Gap.md,
                        start: Gap.md,
                        child: Wrap(
                          spacing: Gap.xs,
                          children: [
                            if (variant.isOnSale)
                              _Badge(text: l10n.saleBadge, color: AppPalette.coral),
                            if (p.isNew)
                              _Badge(
                                  text: l10n.newBadge,
                                  color: AppPalette.sunshine,
                                  textColor: AppPalette.ink),
                          ],
                        ),
                      ),
                      PositionedDirectional(
                        top: Gap.md,
                        end: Gap.md,
                        child: _WishlistHeart(
                          active: wishlisted,
                          visible: _hovered || wishlisted,
                          onTap: () =>
                              ref.read(wishlistProvider.notifier).toggle(p.slug),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        Gap.md, Gap.xs, Gap.md, Gap.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _brandName(ref, p.brandSlug, isAr),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppPalette.inkMuted),
                        ),
                        Text(
                          isAr ? p.nameAr : p.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: Gap.xs),
                        if (p.ratingCount > 0)
                          RatingStars(rating: p.ratingAvg, count: p.ratingCount),
                        const SizedBox(height: Gap.xs),
                        PriceText(
                          price: Money(variant.priceFils),
                          compareAt: variant.compareAtPriceFils == null
                              ? null
                              : Money(variant.compareAtPriceFils!),
                        ),
                        if (!p.inStock)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(top: Gap.xs),
                            child: Text(
                              l10n.outOfStock,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppPalette.error),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _brandName(WidgetRef ref, String slug, bool isAr) {
    final brands = ref.watch(brandsProvider).valueOrNull;
    if (brands == null) return '';
    for (final b in brands) {
      if (b.slug == slug) return isAr ? b.nameAr : b.name;
    }
    return '';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color, this.textColor});

  final String text;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: Gap.sm, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: Corners.chipRadius),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor ?? AppPalette.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _WishlistHeart extends StatelessWidget {
  const _WishlistHeart({
    required this.active,
    required this.visible,
    required this.onTap,
  });

  final bool active;
  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      // Always tappable on touch devices; fades in on hover for pointer devices.
      opacity: visible ? 1 : 0.55,
      child: Material(
        color: AppPalette.white,
        shape: const CircleBorder(),
        elevation: 1,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(6),
            child: Semantics(
              button: true,
              label: 'Wishlist',
              child: Icon(
                active ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                size: 20,
                color: active ? AppPalette.coral : AppPalette.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
