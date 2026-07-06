import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../domain/models.dart';
import 'listing.dart';
import 'providers.dart';

/// Age hub (`/age/3-5`): curated header + filterable grid. The primary
/// browse pattern — parents think in ages, not categories (spec §3.2).
class AgeHubScreen extends ConsumerStatefulWidget {
  const AgeHubScreen({super.key, required this.ageSlug});

  final String ageSlug;

  @override
  ConsumerState<AgeHubScreen> createState() => _AgeHubScreenState();
}

class _AgeHubScreenState extends ConsumerState<AgeHubScreen> {
  late CatalogQuery _query = CatalogQuery(ageSlugs: {widget.ageSlug});

  @override
  Widget build(BuildContext context) {
    final group = ref.watch(ageGroupBySlugProvider(widget.ageSlug));
    final isAr = context.isArabic;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(Gap.lg),
        children: [
          ContentClamp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                group.maybeWhen(
                  data: (g) => g == null
                      ? const SizedBox.shrink()
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsetsDirectional.all(Gap.xl),
                          decoration: BoxDecoration(
                            color: AppPalette.pastel(g.sortOrder),
                            borderRadius: Corners.playfulRadius,
                          ),
                          child: Row(
                            children: [
                              Text(g.emoji, style: const TextStyle(fontSize: 52)),
                              const SizedBox(width: Gap.lg),
                              Expanded(
                                child: Text(
                                  context.l10n.greatForAges(
                                      isAr ? g.labelAr : g.label),
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                  orElse: () => const SizedBox(height: 96),
                ),
                const SizedBox(height: Gap.xl),
                ListingResults(
                  query: _query,
                  onQueryChanged: (q) => setState(
                      () => _query = q.copyWith(ageSlugs: {widget.ageSlug})),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
