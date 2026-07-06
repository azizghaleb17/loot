import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/product_card.dart';
import '../domain/models.dart';
import 'providers.dart';

/// Home (playful mode): search bar → age-group rail (the hero navigation) →
/// promo banner → New arrivals / Best sellers shelves → brand strip →
/// category grid. Spec §3.2.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(newArrivalsProvider);
          ref.invalidate(bestSellersProvider);
        },
        child: ListView(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: Gap.lg, vertical: Gap.lg),
          children: [
            ContentClamp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchBar(hint: l10n.searchHint),
                  const SizedBox(height: Gap.xl),
                  _Hero(title: l10n.heroTitle, subtitle: l10n.heroSubtitle),
                  const SizedBox(height: Gap.xxl),
                  SectionHeader(title: l10n.shopByAge),
                  const _AgeRail(),
                  const SizedBox(height: Gap.xxl),
                  const _PromoBanner(),
                  const SizedBox(height: Gap.xxl),
                  SectionHeader(
                    title: l10n.newArrivals,
                    onSeeAll: () => context.push('/search?section=new'),
                  ),
                  _ProductShelf(provider: newArrivalsProvider),
                  const SizedBox(height: Gap.xxl),
                  SectionHeader(
                    title: l10n.bestSellers,
                    onSeeAll: () => context.push('/search?section=best'),
                  ),
                  _ProductShelf(provider: bestSellersProvider),
                  const SizedBox(height: Gap.xxl),
                  SectionHeader(title: l10n.shopByBrand),
                  const _BrandStrip(),
                  const SizedBox(height: Gap.xxl),
                  SectionHeader(title: l10n.shopByCategory),
                  const _CategoryGrid(),
                  const SizedBox(height: Gap.xxxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: () => context.push('/search'),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, color: AppPalette.inkMuted),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(Gap.xl),
      decoration: BoxDecoration(
        color: AppPalette.sky,
        borderRadius: Corners.playfulRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: Gap.sm),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppPalette.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: Gap.lg),
          const Text('🪁', style: TextStyle(fontSize: 64)),
        ],
      ),
    );
  }
}

/// The signature element: six illustrated pastel age cards.
class _AgeRail extends ConsumerWidget {
  const _AgeRail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ages = ref.watch(ageGroupsProvider);
    final isAr = context.isArabic;

    return ages.when(
      loading: () => const SizedBox(height: 120),
      error: (e, _) => ErrorView(onRetry: () => ref.invalidate(ageGroupsProvider)),
      data: (groups) => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          if (wide) {
            return Row(
              children: [
                for (final (i, g) in groups.indexed) ...[
                  if (i > 0) const SizedBox(width: Gap.md),
                  Expanded(
                    child: AgeCard(
                      emoji: g.emoji,
                      label: isAr ? g.labelAr : g.label,
                      tile: i,
                      ageSlug: g.slug,
                    ),
                  ),
                ],
              ],
            );
          }
          return SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(width: Gap.md),
              itemBuilder: (context, i) => SizedBox(
                width: 120,
                child: AgeCard(
                  emoji: groups[i].emoji,
                  label: isAr ? groups[i].labelAr : groups[i].label,
                  tile: i,
                  ageSlug: groups[i].slug,
                  compact: true,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(Gap.xl),
      decoration: BoxDecoration(
        color: AppPalette.sunshine,
        borderRadius: Corners.playfulRadius,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: Gap.md,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.promoBannerTitle,
                  style: Theme.of(context).textTheme.headlineMedium),
              Text(l10n.promoBannerSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.ink, foregroundColor: AppPalette.white),
            onPressed: () => context.push('/search'),
            child: Text(l10n.promoBannerCta),
          ),
        ],
      ),
    );
  }
}

class _ProductShelf extends ConsumerWidget {
  const _ProductShelf({required this.provider});

  final AutoDisposeFutureProvider<List<Product>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(provider);
    return products.when(
      loading: () => const SizedBox(
          height: 300, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => ErrorView(onRetry: () => ref.invalidate(provider)),
      data: (items) => SizedBox(
        height: 340,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: Gap.lg),
          itemBuilder: (context, i) => SizedBox(
            width: 220,
            child: ProductCard(product: items[i]),
          ),
        ),
      ),
    );
  }
}

class _BrandStrip extends ConsumerWidget {
  const _BrandStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brands = ref.watch(brandsProvider);
    final isAr = context.isArabic;
    return brands.when(
      loading: () => const SizedBox(height: 48),
      error: (e, _) => const SizedBox.shrink(),
      data: (items) => SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: Gap.sm),
          itemBuilder: (context, i) => ActionChip(
            label: Text(isAr ? items[i].nameAr : items[i].name),
            onPressed: () => context.push('/b/${items[i].slug}'),
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends ConsumerWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final isAr = context.isArabic;
    return categories.when(
      loading: () => const SizedBox(height: 200),
      error: (e, _) =>
          ErrorView(onRetry: () => ref.invalidate(categoriesProvider)),
      data: (items) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: Gap.md,
          crossAxisSpacing: Gap.md,
          childAspectRatio: 1.4,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final cat = items[i];
          return Material(
            color: AppPalette.pastel(i),
            borderRadius: Corners.cardRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/c/${cat.slug}'),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(Gap.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(height: Gap.xs),
                    Text(
                      isAr ? cat.nameAr : cat.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
