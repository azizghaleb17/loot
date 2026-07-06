import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../catalog/domain/models.dart';
import '../../catalog/presentation/listing.dart';

/// Search & filter — ALL state lives in query params so filtered views are
/// shareable URLs (spec §3.2): /search?q=&age=&brand=&min=&max=&sort=&stock=
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.params});

  final Map<String, String> params;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.params['q'] ?? '');
  Timer? _debounce;

  CatalogQuery get _query {
    final p = widget.params;
    Set<String> split(String? v) =>
        (v ?? '').split(',').where((s) => s.isNotEmpty).toSet();
    return CatalogQuery(
      text: p['q'],
      ageSlugs: split(p['age']),
      brandSlugs: split(p['brand']),
      minFils: int.tryParse(p['min'] ?? ''),
      maxFils: int.tryParse(p['max'] ?? ''),
      inStockOnly: p['stock'] == '1',
      sort: CatalogSort.values.asNameMap()[p['sort']] ?? CatalogSort.newest,
      section: switch (p['section']) {
        'new' => CatalogSection.newArrivals,
        'best' => CatalogSection.bestSellers,
        _ => null,
      },
    );
  }

  void _push(CatalogQuery q) {
    final params = <String, String>{
      if (q.text != null && q.text!.isNotEmpty) 'q': q.text!,
      if (q.ageSlugs.isNotEmpty) 'age': (q.ageSlugs.toList()..sort()).join(','),
      if (q.brandSlugs.isNotEmpty)
        'brand': (q.brandSlugs.toList()..sort()).join(','),
      if (q.minFils != null) 'min': '${q.minFils}',
      if (q.maxFils != null) 'max': '${q.maxFils}',
      if (q.inStockOnly) 'stock': '1',
      if (q.sort != CatalogSort.newest) 'sort': q.sort.name,
      if (q.section == CatalogSection.newArrivals) 'section': 'new',
      if (q.section == CatalogSection.bestSellers) 'section': 'best',
    };
    context.go(Uri(path: '/search', queryParameters: params.isEmpty ? null : params)
        .toString());
  }

  void _onTextChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _push(_query.copyWith(text: () => text));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(Gap.lg),
        children: [
          ContentClamp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  autofocus: widget.params.isEmpty,
                  onChanged: _onTextChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: context.l10n.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppPalette.inkMuted),
                    suffixIcon: _controller.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _controller.clear();
                              _push(_query.copyWith(text: () => null));
                            },
                          ),
                  ),
                ),
                const SizedBox(height: Gap.lg),
                ListingResults(query: _query, onQueryChanged: _push),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
