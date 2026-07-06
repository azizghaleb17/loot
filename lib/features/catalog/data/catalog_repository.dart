import '../domain/models.dart';
import 'seed_data.dart';

/// The seam between presentation/domain and the backend. The Supabase
/// implementation replaces [DemoCatalogRepository] behind this interface
/// when BackendMode.supabase is configured — screens never change.
abstract interface class CatalogRepository {
  Future<List<AgeGroup>> ageGroups();
  Future<List<Category>> categories();
  Future<List<Brand>> brands();
  Future<Product?> productBySlug(String slug);
  Future<Brand?> brandBySlug(String slug);
  Future<Category?> categoryBySlug(String slug);
  Future<AgeGroup?> ageGroupBySlug(String slug);
  Future<List<Product>> query(CatalogQuery q);
}

class DemoCatalogRepository implements CatalogRepository {
  const DemoCatalogRepository();

  @override
  Future<List<AgeGroup>> ageGroups() async => seedAgeGroups;

  @override
  Future<List<Category>> categories() async => seedCategories;

  @override
  Future<List<Brand>> brands() async => seedBrands;

  @override
  Future<Product?> productBySlug(String slug) async {
    for (final p in seedProducts) {
      if (p.slug == slug) return p;
    }
    return null;
  }

  @override
  Future<Brand?> brandBySlug(String slug) async {
    for (final b in seedBrands) {
      if (b.slug == slug) return b;
    }
    return null;
  }

  @override
  Future<Category?> categoryBySlug(String slug) async {
    for (final c in seedCategories) {
      if (c.slug == slug) return c;
    }
    return null;
  }

  @override
  Future<AgeGroup?> ageGroupBySlug(String slug) async {
    for (final a in seedAgeGroups) {
      if (a.slug == slug) return a;
    }
    return null;
  }

  @override
  Future<List<Product>> query(CatalogQuery q) async {
    Iterable<Product> results = seedProducts;

    if (q.section == CatalogSection.newArrivals) {
      results = results.where((p) => p.isNew);
    } else if (q.section == CatalogSection.bestSellers) {
      results = results.where((p) => p.isBestSeller);
    }
    if (q.categorySlug != null) {
      results = results.where((p) => p.categorySlugs.contains(q.categorySlug));
    }
    if (q.ageSlugs.isNotEmpty) {
      results = results.where((p) => p.ageSlugs.any(q.ageSlugs.contains));
    }
    if (q.brandSlugs.isNotEmpty) {
      results = results.where((p) => q.brandSlugs.contains(p.brandSlug));
    }
    if (q.minFils != null) {
      results = results.where((p) => p.defaultVariant.priceFils >= q.minFils!);
    }
    if (q.maxFils != null) {
      results = results.where((p) => p.defaultVariant.priceFils <= q.maxFils!);
    }
    if (q.inStockOnly) {
      results = results.where((p) => p.inStock);
    }
    if (q.text != null && q.text!.trim().isNotEmpty) {
      final terms = q.text!.toLowerCase().trim().split(RegExp(r'\s+'));
      results = results.where((p) {
        final haystack = '${p.name} ${p.nameAr} ${p.description} '
                '${p.descriptionAr} ${p.brandSlug}'
            .toLowerCase();
        return terms.every(haystack.contains);
      });
    }

    final list = results.toList();
    switch (q.sort) {
      case CatalogSort.newest:
        // Seed order is curated; new items float first.
        list.sort((a, b) => (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0));
      case CatalogSort.priceAsc:
        list.sort((a, b) =>
            a.defaultVariant.priceFils.compareTo(b.defaultVariant.priceFils));
      case CatalogSort.priceDesc:
        list.sort((a, b) =>
            b.defaultVariant.priceFils.compareTo(a.defaultVariant.priceFils));
      case CatalogSort.rating:
        list.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    }
    return list;
  }
}
