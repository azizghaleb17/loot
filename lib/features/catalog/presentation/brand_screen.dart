import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../domain/models.dart';
import 'listing.dart';
import 'providers.dart';

class BrandScreen extends ConsumerStatefulWidget {
  const BrandScreen({super.key, required this.brandSlug});

  final String brandSlug;

  @override
  ConsumerState<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends ConsumerState<BrandScreen> {
  late CatalogQuery _query = CatalogQuery(brandSlugs: {widget.brandSlug});

  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandBySlugProvider(widget.brandSlug));
    final isAr = context.isArabic;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(Gap.lg),
        children: [
          ContentClamp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                brand.maybeWhen(
                  data: (b) => SectionHeader(
                      title: b == null
                          ? widget.brandSlug
                          : (isAr ? b.nameAr : b.name)),
                  orElse: () => const SizedBox(height: 40),
                ),
                ListingResults(
                  query: _query,
                  // Pin this brand but preserve extra brands from the sheet.
                  onQueryChanged: (q) => setState(() => _query = q.copyWith(
                      brandSlugs: {widget.brandSlug, ...q.brandSlugs})),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
