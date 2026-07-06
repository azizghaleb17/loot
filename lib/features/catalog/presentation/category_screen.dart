import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../domain/models.dart';
import 'listing.dart';
import 'providers.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key, required this.categorySlug});

  final String categorySlug;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  late CatalogQuery _query = CatalogQuery(categorySlug: widget.categorySlug);

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(categoryBySlugProvider(widget.categorySlug));
    final isAr = context.isArabic;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(Gap.lg),
        children: [
          ContentClamp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                category.maybeWhen(
                  data: (c) => SectionHeader(
                    title: c == null
                        ? widget.categorySlug
                        : '${c.emoji}  ${isAr ? c.nameAr : c.name}',
                  ),
                  orElse: () => const SizedBox(height: 40),
                ),
                ListingResults(
                  query: _query,
                  onQueryChanged: (q) => setState(() => _query =
                      q.copyWith(categorySlug: () => widget.categorySlug)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
