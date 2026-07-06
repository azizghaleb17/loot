import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog_repository.dart';
import '../domain/models.dart';

/// Demo backend for this phase; the Supabase implementation is swapped in
/// here (and only here) when BackendMode.supabase ships.
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => const DemoCatalogRepository(),
);

// keepAlive providers double as the session cache (spec §1.4 tier 1).
final ageGroupsProvider = FutureProvider<List<AgeGroup>>(
  (ref) => ref.watch(catalogRepositoryProvider).ageGroups(),
);

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(catalogRepositoryProvider).categories(),
);

final brandsProvider = FutureProvider<List<Brand>>(
  (ref) => ref.watch(catalogRepositoryProvider).brands(),
);

final productBySlugProvider = FutureProvider.family<Product?, String>(
  (ref, slug) => ref.watch(catalogRepositoryProvider).productBySlug(slug),
);

final brandBySlugProvider = FutureProvider.family<Brand?, String>(
  (ref, slug) => ref.watch(catalogRepositoryProvider).brandBySlug(slug),
);

final categoryBySlugProvider = FutureProvider.family<Category?, String>(
  (ref, slug) => ref.watch(catalogRepositoryProvider).categoryBySlug(slug),
);

final ageGroupBySlugProvider = FutureProvider.family<AgeGroup?, String>(
  (ref, slug) => ref.watch(catalogRepositoryProvider).ageGroupBySlug(slug),
);

final newArrivalsProvider = FutureProvider.autoDispose<List<Product>>(
  (ref) => ref
      .watch(catalogRepositoryProvider)
      .query(const CatalogQuery(section: CatalogSection.newArrivals)),
);

final bestSellersProvider = FutureProvider.autoDispose<List<Product>>(
  (ref) => ref
      .watch(catalogRepositoryProvider)
      .query(const CatalogQuery(section: CatalogSection.bestSellers)),
);

/// Per-query results, cached on CatalogQuery value equality.
final catalogQueryProvider =
    FutureProvider.autoDispose.family<List<Product>, CatalogQuery>(
  (ref, q) => ref.watch(catalogRepositoryProvider).query(q),
);
