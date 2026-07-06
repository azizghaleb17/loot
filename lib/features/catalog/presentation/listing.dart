import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/product_card.dart';
import '../domain/models.dart';
import 'providers.dart';

/// Shared listing surface for age hub / category / brand / search: results
/// count, sort control, filter sheet, active-filter chips, responsive grid.
class ListingResults extends ConsumerWidget {
  const ListingResults({
    super.key,
    required this.query,
    required this.onQueryChanged,
    this.showCategoryFilter = false,
  });

  final CatalogQuery query;
  final ValueChanged<CatalogQuery> onQueryChanged;
  final bool showCategoryFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final results = ref.watch(catalogQueryProvider(query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: results.maybeWhen(
                data: (items) => Text(
                  l10n.resultsCount(items.length),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppPalette.inkMuted),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
            _SortMenu(
              value: query.sort,
              onChanged: (s) => onQueryChanged(query.copyWith(sort: s)),
            ),
            const SizedBox(width: Gap.sm),
            OutlinedButton.icon(
              onPressed: () => _openFilterSheet(context, ref),
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: Text(l10n.filters),
            ),
          ],
        ),
        _ActiveFilterChips(query: query, onQueryChanged: onQueryChanged),
        const SizedBox(height: Gap.lg),
        results.when(
          loading: () => const Padding(
            padding: EdgeInsetsDirectional.all(Gap.xxl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) =>
              ErrorView(onRetry: () => ref.invalidate(catalogQueryProvider(query))),
          data: (items) => items.isEmpty
              ? EmptyState(
                  emoji: '🔍',
                  title: l10n.noResults,
                  hint: l10n.noResultsHint,
                )
              : ProductGrid(
                  children: [for (final p in items) ProductCard(product: p)],
                ),
        ),
      ],
    );
  }

  Future<void> _openFilterSheet(BuildContext context, WidgetRef ref) async {
    final updated = await showModalBottomSheet<CatalogQuery>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(initial: query),
    );
    if (updated != null) onQueryChanged(updated);
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.value, required this.onChanged});

  final CatalogSort value;
  final ValueChanged<CatalogSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      CatalogSort.newest: l10n.sortNewest,
      CatalogSort.priceAsc: l10n.sortPriceAsc,
      CatalogSort.priceDesc: l10n.sortPriceDesc,
      CatalogSort.rating: l10n.sortRating,
    };
    return PopupMenuButton<CatalogSort>(
      initialValue: value,
      onSelected: onChanged,
      tooltip: l10n.sortBy,
      itemBuilder: (context) => [
        for (final entry in labels.entries)
          PopupMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
            horizontal: Gap.md, vertical: Gap.sm),
        decoration: BoxDecoration(
          border: Border.all(color: AppPalette.hairline),
          borderRadius: Corners.chipRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 18, color: AppPalette.teal),
            const SizedBox(width: Gap.xs),
            Text(labels[value]!, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _ActiveFilterChips extends ConsumerWidget {
  const _ActiveFilterChips({required this.query, required this.onQueryChanged});

  final CatalogQuery query;
  final ValueChanged<CatalogQuery> onQueryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chips = <Widget>[];
    final ages = ref.watch(ageGroupsProvider).valueOrNull ?? [];
    final brands = ref.watch(brandsProvider).valueOrNull ?? [];
    final isAr = context.isArabic;
    final lang = isAr ? 'ar' : 'en';

    for (final slug in query.ageSlugs) {
      final label = ages
          .where((a) => a.slug == slug)
          .map((a) => isAr ? a.labelAr : a.label)
          .firstOrNull;
      chips.add(InputChip(
        label: Text(label ?? slug),
        onDeleted: () => onQueryChanged(
            query.copyWith(ageSlugs: {...query.ageSlugs}..remove(slug))),
      ));
    }
    for (final slug in query.brandSlugs) {
      final label = brands
          .where((b) => b.slug == slug)
          .map((b) => isAr ? b.nameAr : b.name)
          .firstOrNull;
      chips.add(InputChip(
        label: Text(label ?? slug),
        onDeleted: () => onQueryChanged(
            query.copyWith(brandSlugs: {...query.brandSlugs}..remove(slug))),
      ));
    }
    if (query.minFils != null || query.maxFils != null) {
      final min = Money(query.minFils ?? 0).format(lang);
      final max = query.maxFils == null ? '∞' : Money(query.maxFils!).format(lang);
      chips.add(InputChip(
        label: Text('$min – $max'),
        onDeleted: () => onQueryChanged(
            query.copyWith(minFils: () => null, maxFils: () => null)),
      ));
    }
    if (query.inStockOnly) {
      chips.add(InputChip(
        label: Text(context.l10n.inStockOnly),
        onDeleted: () => onQueryChanged(query.copyWith(inStockOnly: false)),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: Gap.md),
      child: Wrap(spacing: Gap.sm, runSpacing: Gap.sm, children: chips),
    );
  }
}

/// Filter sheet: age (multi), price range (KWD), brand (multi), in-stock.
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initial});

  final CatalogQuery initial;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late Set<String> _ages = {...widget.initial.ageSlugs};
  late Set<String> _brands = {...widget.initial.brandSlugs};
  late bool _inStock = widget.initial.inStockOnly;
  late RangeValues _price = RangeValues(
    (widget.initial.minFils ?? 0) / 1000,
    (widget.initial.maxFils ?? 50000) / 1000,
  );

  static const _maxKd = 50.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = context.isArabic;
    final ages = ref.watch(ageGroupsProvider).valueOrNull ?? [];
    final brands = ref.watch(brandsProvider).valueOrNull ?? [];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(Gap.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.filters,
                      style: Theme.of(context).textTheme.headlineMedium),
                  TextButton(
                    onPressed: () => setState(() {
                      _ages = {};
                      _brands = {};
                      _inStock = false;
                      _price = const RangeValues(0, _maxKd);
                    }),
                    child: Text(l10n.reset),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Text(l10n.ageFilter, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Gap.sm),
              Wrap(
                spacing: Gap.sm,
                runSpacing: Gap.sm,
                children: [
                  for (final a in ages)
                    FilterChip(
                      label: Text(isAr ? a.labelAr : a.label),
                      selected: _ages.contains(a.slug),
                      onSelected: (v) => setState(() =>
                          v ? _ages.add(a.slug) : _ages.remove(a.slug)),
                    ),
                ],
              ),
              const SizedBox(height: Gap.lg),
              Text(l10n.priceRange, style: Theme.of(context).textTheme.titleMedium),
              RangeSlider(
                values: _price,
                min: 0,
                max: _maxKd,
                divisions: 50,
                activeColor: AppPalette.teal,
                labels: RangeLabels(
                  _price.start.toStringAsFixed(0),
                  _price.end.toStringAsFixed(0),
                ),
                onChanged: (v) => setState(() => _price = v),
              ),
              const SizedBox(height: Gap.lg),
              Text(l10n.brandsFilter,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Gap.sm),
              Wrap(
                spacing: Gap.sm,
                runSpacing: Gap.sm,
                children: [
                  for (final b in brands)
                    FilterChip(
                      label: Text(isAr ? b.nameAr : b.name),
                      selected: _brands.contains(b.slug),
                      onSelected: (v) => setState(() =>
                          v ? _brands.add(b.slug) : _brands.remove(b.slug)),
                    ),
                ],
              ),
              const SizedBox(height: Gap.lg),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.inStockOnly),
                value: _inStock,
                activeThumbColor: AppPalette.teal,
                onChanged: (v) => setState(() => _inStock = v),
              ),
              const SizedBox(height: Gap.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(
                    widget.initial.copyWith(
                      ageSlugs: _ages,
                      brandSlugs: _brands,
                      inStockOnly: _inStock,
                      minFils: () =>
                          _price.start <= 0 ? null : (_price.start * 1000).round(),
                      maxFils: () =>
                          _price.end >= _maxKd ? null : (_price.end * 1000).round(),
                    ),
                  ),
                  child: Text(l10n.apply),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
