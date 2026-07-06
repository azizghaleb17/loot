import 'package:flutter/foundation.dart';

/// Six first-class browse dimensions — parents think in ages, not categories.
@immutable
class AgeGroup {
  const AgeGroup({
    required this.slug,
    required this.label,
    required this.labelAr,
    required this.minMonths,
    this.maxMonths,
    required this.sortOrder,
    required this.emoji,
  });

  final String slug;
  final String label;
  final String labelAr;
  final int minMonths;
  final int? maxMonths; // null = open-ended (12y+)
  final int sortOrder;
  final String emoji;
}

@immutable
class Category {
  const Category({
    required this.slug,
    required this.name,
    required this.nameAr,
    required this.emoji,
    required this.sortOrder,
  });

  final String slug;
  final String name;
  final String nameAr;
  final String emoji;
  final int sortOrder;
}

@immutable
class Brand {
  const Brand({required this.slug, required this.name, required this.nameAr});

  final String slug;
  final String name;
  final String nameAr;
}

@immutable
class Variant {
  const Variant({
    required this.sku,
    this.name = '',
    this.nameAr = '',
    required this.priceFils,
    this.compareAtPriceFils,
    required this.stockQty,
    this.isDefault = false,
  });

  final String sku; // doubles as the variant id in demo mode
  final String name;
  final String nameAr;
  final int priceFils;
  final int? compareAtPriceFils;
  final int stockQty;
  final bool isDefault;

  bool get isOnSale => compareAtPriceFils != null && compareAtPriceFils! > priceFils;
  bool get inStock => stockQty > 0;
}

@immutable
class Product {
  const Product({
    required this.slug,
    required this.name,
    required this.nameAr,
    required this.brandSlug,
    required this.description,
    required this.descriptionAr,
    this.safetyNotes,
    required this.ageSlugs,
    required this.categorySlugs,
    required this.emoji,
    required this.tile,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.isNew = false,
    this.isBestSeller = false,
    required this.variants, // invariant: ≥1 variant (enforced by seed tests + DB)
  });

  final String slug;
  final String name;
  final String nameAr;
  final String brandSlug;
  final String description;
  final String descriptionAr;
  final String? safetyNotes;
  final List<String> ageSlugs;
  final List<String> categorySlugs;

  /// Demo imagery: emoji sticker on a pastel tile (index into AppPalette.pastels).
  /// Replaced by Supabase Storage photo URLs when the real backend is wired.
  final String emoji;
  final int tile;

  final double ratingAvg;
  final int ratingCount;
  final bool isNew;
  final bool isBestSeller;
  final List<Variant> variants;

  Variant get defaultVariant =>
      variants.firstWhere((v) => v.isDefault, orElse: () => variants.first);
  bool get inStock => variants.any((v) => v.inStock);
  bool get isOnSale => defaultVariant.isOnSale;
  int get minPriceFils =>
      variants.map((v) => v.priceFils).reduce((a, b) => a < b ? a : b);
  Variant? variantBySku(String sku) {
    for (final v in variants) {
      if (v.sku == sku) return v;
    }
    return null;
  }
}

enum CatalogSort { newest, priceAsc, priceDesc, rating }

enum CatalogSection { newArrivals, bestSellers }

@immutable
class CatalogQuery {
  const CatalogQuery({
    this.text,
    this.ageSlugs = const {},
    this.categorySlug,
    this.brandSlugs = const {},
    this.minFils,
    this.maxFils,
    this.inStockOnly = false,
    this.sort = CatalogSort.newest,
    this.section,
  });

  final String? text;
  final Set<String> ageSlugs;
  final String? categorySlug;
  final Set<String> brandSlugs;
  final int? minFils;
  final int? maxFils;
  final bool inStockOnly;
  final CatalogSort sort;
  final CatalogSection? section;

  CatalogQuery copyWith({
    String? Function()? text,
    Set<String>? ageSlugs,
    String? Function()? categorySlug,
    Set<String>? brandSlugs,
    int? Function()? minFils,
    int? Function()? maxFils,
    bool? inStockOnly,
    CatalogSort? sort,
    CatalogSection? Function()? section,
  }) =>
      CatalogQuery(
        text: text != null ? text() : this.text,
        ageSlugs: ageSlugs ?? this.ageSlugs,
        categorySlug: categorySlug != null ? categorySlug() : this.categorySlug,
        brandSlugs: brandSlugs ?? this.brandSlugs,
        minFils: minFils != null ? minFils() : this.minFils,
        maxFils: maxFils != null ? maxFils() : this.maxFils,
        inStockOnly: inStockOnly ?? this.inStockOnly,
        sort: sort ?? this.sort,
        section: section != null ? section() : this.section,
      );

  /// Stable identity so provider families can cache per-query.
  String get _key => [
        text ?? '',
        (ageSlugs.toList()..sort()).join(','),
        categorySlug ?? '',
        (brandSlugs.toList()..sort()).join(','),
        '$minFils',
        '$maxFils',
        '$inStockOnly',
        sort.name,
        section?.name ?? '',
      ].join('|');

  @override
  bool operator ==(Object other) => other is CatalogQuery && other._key == _key;

  @override
  int get hashCode => _key.hashCode;
}
