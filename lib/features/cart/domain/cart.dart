import 'package:flutter/foundation.dart';

import '../../../core/utils/money.dart';
import '../../catalog/domain/models.dart';

@immutable
class CartLine {
  const CartLine({
    required this.productSlug,
    required this.sku,
    required this.qty,
  });

  final String productSlug;
  final String sku; // variant sku
  final int qty;

  CartLine copyWith({int? qty}) =>
      CartLine(productSlug: productSlug, sku: sku, qty: qty ?? this.qty);

  Map<String, dynamic> toJson() =>
      {'productSlug': productSlug, 'sku': sku, 'qty': qty};

  factory CartLine.fromJson(Map<dynamic, dynamic> json) => CartLine(
        productSlug: json['productSlug'] as String,
        sku: json['sku'] as String,
        qty: json['qty'] as int,
      );
}

@immutable
class CartState {
  const CartState({this.lines = const [], this.promoCode});

  final List<CartLine> lines;
  final String? promoCode;

  int get itemCount => lines.fold(0, (sum, l) => sum + l.qty);
  bool get isEmpty => lines.isEmpty;

  CartState copyWith({List<CartLine>? lines, String? Function()? promoCode}) =>
      CartState(
        lines: lines ?? this.lines,
        promoCode: promoCode != null ? promoCode() : this.promoCode,
      );
}

enum PromoType { percent, fixed, freeShipping }

@immutable
class Promo {
  const Promo({
    required this.code,
    required this.type,
    required this.value,
    this.minOrder = Money.zero,
  });

  final String code;
  final PromoType type;
  final int value; // percent 0–100, or fils for fixed
  final Money minOrder;
}

/// Demo promotions — mirrored in supabase/seed/seed.sql.
const demoPromos = <Promo>[
  Promo(code: 'LOOT10', type: PromoType.percent, value: 10),
  Promo(code: 'FREESHIP', type: PromoType.freeShipping, value: 0, minOrder: Money(5000)),
];

/// Shipping policy — must match supabase/migrations/0003_place_order.sql.
const flatShipping = Money(2000); // 2.000 KD
const freeShippingMin = Money(15000); // free ≥ 15.000 KD

/// A cart line joined with its catalog product/variant, ready to render.
@immutable
class ResolvedLine {
  const ResolvedLine({
    required this.line,
    required this.product,
    required this.variant,
  });

  final CartLine line;
  final Product product;
  final Variant variant;

  Money get unitPrice => Money(variant.priceFils);
  Money get lineTotal => unitPrice * line.qty;
}

@immutable
class CartTotals {
  const CartTotals({
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.promoApplied,
  });

  final Money subtotal;
  final Money shipping;
  final Money discount;
  final Promo? promoApplied;

  /// Kuwait has no VAT today; orders still model a tax line (always 0 here).
  Money get tax => Money.zero;

  Money get total => Money(
      subtotal.fils - discount.fils + shipping.fils + tax.fils);

  static CartTotals compute(List<ResolvedLine> lines, String? promoCode) {
    final subtotal =
        lines.fold(Money.zero, (sum, l) => sum + l.lineTotal);

    var shipping = subtotal >= freeShippingMin || subtotal.isZero
        ? Money.zero
        : flatShipping;
    var discount = Money.zero;
    Promo? applied;

    if (promoCode != null) {
      for (final promo in demoPromos) {
        if (promo.code == promoCode.toUpperCase() && subtotal >= promo.minOrder) {
          applied = promo;
          switch (promo.type) {
            case PromoType.percent:
              discount = subtotal.percent(promo.value);
            case PromoType.fixed:
              discount = Money(promo.value) <= subtotal
                  ? Money(promo.value)
                  : subtotal;
            case PromoType.freeShipping:
              shipping = Money.zero;
          }
          break;
        }
      }
    }

    return CartTotals(
      subtotal: subtotal,
      shipping: shipping,
      discount: discount,
      promoApplied: applied,
    );
  }
}
