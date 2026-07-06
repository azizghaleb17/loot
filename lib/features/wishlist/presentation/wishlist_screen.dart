import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/product_card.dart';
import '../../catalog/domain/models.dart';
import '../../catalog/presentation/providers.dart';
import 'wishlist_providers.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final slugs = ref.watch(wishlistProvider);

    if (slugs.isEmpty) {
      return SafeArea(
        child: EmptyState(
          emoji: '💛',
          title: l10n.wishlistEmpty,
          hint: l10n.wishlistEmptyHint,
          actionLabel: l10n.startShopping,
          onAction: () => context.go('/'),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(Gap.lg),
        children: [
          ContentClamp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.wishlistTitle,
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: Gap.lg),
                _WishGrid(slugs: slugs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WishGrid extends ConsumerWidget {
  const _WishGrid({required this.slugs});

  final Set<String> slugs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = <Product>[];
    for (final slug in slugs) {
      final p = ref.watch(productBySlugProvider(slug)).valueOrNull;
      if (p != null) products.add(p);
    }
    return ProductGrid(
      children: [for (final p in products) ProductCard(product: p)],
    );
  }
}
