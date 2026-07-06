import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../../core/utils/money.dart';
import '../../catalog/presentation/providers.dart';
import '../domain/cart.dart';

const _cartBoxName = 'cart';

/// Guest cart — persisted to Hive (IndexedDB on web) per spec §1.4.
/// On sign-in (Phase 2 backend wiring) this merges into the server cart:
/// server wins on conflicts, quantities summed.
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => _load();

  Box get _box => Hive.box(_cartBoxName);

  CartState _load() {
    final raw = _box.get('lines', defaultValue: <dynamic>[]) as List;
    final promo = _box.get('promoCode') as String?;
    return CartState(
      lines: raw
          .map((e) => CartLine.fromJson(Map<dynamic, dynamic>.from(e as Map)))
          .toList(),
      promoCode: promo,
    );
  }

  void _persist() {
    _box.put('lines', state.lines.map((l) => l.toJson()).toList());
    _box.put('promoCode', state.promoCode);
  }

  void add(String productSlug, String sku, {int qty = 1}) {
    final existing = state.lines.indexWhere((l) => l.sku == sku);
    final lines = [...state.lines];
    if (existing >= 0) {
      lines[existing] = lines[existing].copyWith(qty: lines[existing].qty + qty);
    } else {
      lines.add(CartLine(productSlug: productSlug, sku: sku, qty: qty));
    }
    state = state.copyWith(lines: lines);
    _persist();
  }

  void setQty(String sku, int qty) {
    if (qty <= 0) {
      remove(sku);
      return;
    }
    state = state.copyWith(lines: [
      for (final l in state.lines) l.sku == sku ? l.copyWith(qty: qty) : l,
    ]);
    _persist();
  }

  /// Returns the removed line so the UI can offer undo.
  CartLine? remove(String sku) {
    CartLine? removed;
    final lines = <CartLine>[];
    for (final l in state.lines) {
      if (l.sku == sku) {
        removed = l;
      } else {
        lines.add(l);
      }
    }
    state = state.copyWith(lines: lines);
    _persist();
    return removed;
  }

  void restore(CartLine line) {
    state = state.copyWith(lines: [...state.lines, line]);
    _persist();
  }

  /// Applies a promo code; returns false when the code is invalid or the
  /// subtotal is below the promo's minimum, so the field can show an error
  /// instead of a false "applied" state.
  bool applyPromo(String code, Money subtotal) {
    final promo = findEligiblePromo(code, subtotal);
    if (promo == null) return false;
    state = state.copyWith(promoCode: () => promo.code);
    _persist();
    return true;
  }

  void clearPromo() {
    state = state.copyWith(promoCode: () => null);
    _persist();
  }

  void clear() {
    state = const CartState();
    _persist();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

/// Cart lines joined with catalog data. Lines whose product/variant vanished
/// from the catalog are dropped silently (stale guest carts).
final resolvedCartProvider = FutureProvider.autoDispose<List<ResolvedLine>>((ref) async {
  final cart = ref.watch(cartProvider);
  final repo = ref.watch(catalogRepositoryProvider);
  final resolved = <ResolvedLine>[];
  for (final line in cart.lines) {
    final product = await repo.productBySlug(line.productSlug);
    final variant = product?.variantBySku(line.sku);
    if (product != null && variant != null) {
      resolved.add(ResolvedLine(line: line, product: product, variant: variant));
    }
  }
  return resolved;
});

final cartTotalsProvider = FutureProvider.autoDispose<CartTotals>((ref) async {
  final lines = await ref.watch(resolvedCartProvider.future);
  final promo = ref.watch(cartProvider.select((c) => c.promoCode));
  return CartTotals.compute(lines, promo);
});

final cartCountProvider =
    Provider<int>((ref) => ref.watch(cartProvider).itemCount);
