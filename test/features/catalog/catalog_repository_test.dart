import 'package:flutter_test/flutter_test.dart';
import 'package:loot/features/catalog/data/catalog_repository.dart';
import 'package:loot/features/catalog/data/seed_data.dart';
import 'package:loot/features/catalog/domain/models.dart';

void main() {
  const repo = DemoCatalogRepository();

  group('seed data invariants', () {
    test('40–60 active products, each with ≥1 variant and a default', () {
      expect(seedProducts.length, inInclusiveRange(40, 60));
      for (final p in seedProducts) {
        expect(p.variants, isNotEmpty, reason: p.slug);
        expect(p.defaultVariant, isNotNull, reason: p.slug);
      }
    });

    test('slugs are unique (URLs must never collide)', () {
      final slugs = seedProducts.map((p) => p.slug).toSet();
      expect(slugs.length, seedProducts.length);
      final skus = seedProducts.expand((p) => p.variants).map((v) => v.sku).toSet();
      expect(skus.length,
          seedProducts.expand((p) => p.variants).length);
    });

    test('every product references valid brand/category/age slugs', () {
      final brands = seedBrands.map((b) => b.slug).toSet();
      final cats = seedCategories.map((c) => c.slug).toSet();
      final ages = seedAgeGroups.map((a) => a.slug).toSet();
      for (final p in seedProducts) {
        expect(brands, contains(p.brandSlug), reason: p.slug);
        for (final c in p.categorySlugs) {
          expect(cats, contains(c), reason: p.slug);
        }
        for (final a in p.ageSlugs) {
          expect(ages, contains(a), reason: p.slug);
        }
      }
    });

    test('compare-at prices are strictly above sale prices', () {
      for (final v in seedProducts.expand((p) => p.variants)) {
        if (v.compareAtPriceFils != null) {
          expect(v.compareAtPriceFils! > v.priceFils, isTrue, reason: v.sku);
        }
      }
    });
  });

  group('query', () {
    test('filters by age group', () async {
      final results = await repo.query(const CatalogQuery(ageSlugs: {'0-12m'}));
      expect(results, isNotEmpty);
      for (final p in results) {
        expect(p.ageSlugs, contains('0-12m'));
      }
    });

    test('filters by category and brand together', () async {
      final results = await repo.query(const CatalogQuery(
          categorySlug: 'building-blocks', brandSlugs: {'lego'}));
      expect(results, isNotEmpty);
      for (final p in results) {
        expect(p.categorySlugs, contains('building-blocks'));
        expect(p.brandSlug, 'lego');
      }
    });

    test('price range filters on the default variant', () async {
      final results =
          await repo.query(const CatalogQuery(minFils: 5000, maxFils: 10000));
      for (final p in results) {
        expect(p.defaultVariant.priceFils, inInclusiveRange(5000, 10000));
      }
    });

    test('text search matches English and Arabic', () async {
      final en = await repo.query(const CatalogQuery(text: 'train'));
      expect(en.map((p) => p.slug), contains('wooden-train-set'));
      final ar = await repo.query(const CatalogQuery(text: 'القطار'));
      expect(ar.map((p) => p.slug), contains('wooden-train-set'));
    });

    test('sort by price ascending', () async {
      final results =
          await repo.query(const CatalogQuery(sort: CatalogSort.priceAsc));
      for (var i = 1; i < results.length; i++) {
        expect(
          results[i].defaultVariant.priceFils >=
              results[i - 1].defaultVariant.priceFils,
          isTrue,
        );
      }
    });

    test('sections return only flagged products', () async {
      final newArrivals = await repo
          .query(const CatalogQuery(section: CatalogSection.newArrivals));
      expect(newArrivals, isNotEmpty);
      expect(newArrivals.every((p) => p.isNew), isTrue);
      final best = await repo
          .query(const CatalogQuery(section: CatalogSection.bestSellers));
      expect(best, isNotEmpty);
      expect(best.every((p) => p.isBestSeller), isTrue);
    });

    test('productBySlug returns null for unknown slugs', () async {
      expect(await repo.productBySlug('does-not-exist'), isNull);
      expect((await repo.productBySlug('wooden-train-set'))?.name,
          'Wooden Train Set — 45 pieces');
    });
  });
}
