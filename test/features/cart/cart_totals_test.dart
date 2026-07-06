import 'package:flutter_test/flutter_test.dart';
import 'package:loot/core/utils/money.dart';
import 'package:loot/features/cart/domain/cart.dart';
import 'package:loot/features/catalog/domain/models.dart';

ResolvedLine line({required int priceFils, required int qty, String sku = 'X'}) {
  final variant = Variant(sku: sku, priceFils: priceFils, stockQty: 99, isDefault: true);
  final product = Product(
    slug: 'p-$sku',
    name: 'P',
    nameAr: 'P',
    brandSlug: 'b',
    description: '',
    descriptionAr: '',
    ageSlugs: const ['3-5'],
    categorySlugs: const ['puzzles'],
    emoji: '🧸',
    tile: 0,
    variants: [variant],
  );
  return ResolvedLine(
    line: CartLine(productSlug: product.slug, sku: sku, qty: qty),
    product: product,
    variant: variant,
  );
}

void main() {
  group('CartTotals', () {
    test('sums line totals; flat 2.000 KD shipping under the free threshold', () {
      final t = CartTotals.compute([line(priceFils: 3500, qty: 2)], null);
      expect(t.subtotal, const Money(7000));
      expect(t.shipping, flatShipping);
      expect(t.discount, Money.zero);
      expect(t.total, const Money(9000));
    });

    test('free shipping at 15.000 KD subtotal and above', () {
      final t = CartTotals.compute([line(priceFils: 15000, qty: 1)], null);
      expect(t.shipping, Money.zero);
      expect(t.total, const Money(15000));
    });

    test('LOOT10 takes 10% off the subtotal, shipping unaffected', () {
      final t = CartTotals.compute([line(priceFils: 9999, qty: 1)], 'LOOT10');
      expect(t.discount, const Money(999)); // truncated, matches SQL
      expect(t.shipping, flatShipping);
      expect(t.total, const Money(9999 - 999 + 2000));
    });

    test('promo codes are case-insensitive', () {
      final t = CartTotals.compute([line(priceFils: 10000, qty: 1)], 'loot10');
      expect(t.discount, const Money(1000));
    });

    test('FREESHIP zeroes shipping when its minimum is met', () {
      final t = CartTotals.compute([line(priceFils: 5000, qty: 1)], 'FREESHIP');
      expect(t.shipping, Money.zero);
      expect(t.discount, Money.zero);
      expect(t.total, const Money(5000));
    });

    test('FREESHIP below its minimum order does not apply', () {
      final t = CartTotals.compute([line(priceFils: 4000, qty: 1)], 'FREESHIP');
      expect(t.promoApplied, isNull);
      expect(t.shipping, flatShipping);
    });

    test('unknown promo applies nothing', () {
      final t = CartTotals.compute([line(priceFils: 5000, qty: 1)], 'NOPE');
      expect(t.promoApplied, isNull);
      expect(t.discount, Money.zero);
    });

    test('tax line exists and is zero (Kuwait has no VAT today)', () {
      final t = CartTotals.compute([line(priceFils: 5000, qty: 1)], null);
      expect(t.tax, Money.zero);
    });

    test('findEligiblePromo rejects codes below their minimum order', () {
      expect(findEligiblePromo('FREESHIP', const Money(4000)), isNull);
      expect(findEligiblePromo('FREESHIP', const Money(5000))?.code, 'FREESHIP');
      expect(findEligiblePromo('loot10', const Money(100))?.code, 'LOOT10');
      expect(findEligiblePromo('NOPE', const Money(99000)), isNull);
      expect(findEligiblePromo(null, const Money(99000)), isNull);
    });

    test('empty cart totals are all zero', () {
      final t = CartTotals.compute(const [], null);
      expect(t.subtotal, Money.zero);
      expect(t.shipping, Money.zero);
      expect(t.total, Money.zero);
    });
  });
}
