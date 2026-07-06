import 'package:hive_ce/hive.dart';

import '../../cart/domain/cart.dart';
import '../domain/order.dart';

/// Order placement + lookup seam. The Supabase implementation calls the
/// `create-payment` edge function (which runs `place_order` server-side and
/// returns a MyFatoorah hosted-page URL); the demo implementation mirrors that
/// contract locally so the full checkout flow is exercisable without
/// credentials.
abstract interface class OrderRepository {
  /// Places the order. For KNET/card the returned order starts as
  /// [OrderStatus.pendingPayment]; COD starts as [OrderStatus.codConfirmed].
  Future<Order> place(DraftOrder draft, List<ResolvedLine> lines);

  /// Marks a pending-payment order paid (demo stand-in for the MyFatoorah
  /// webhook). Returns the updated order.
  Future<Order?> confirmPayment(String orderNo, {required bool success});

  Future<List<Order>> recentOrders();

  /// Guest order lookup: order number + phone (spec §3.2).
  Future<Order?> byNumberAndPhone(String orderNo, String phone);
}

const _ordersBoxName = 'orders';

class DemoOrderRepository implements OrderRepository {
  Box get _box => Hive.box(_ordersBoxName);

  @override
  Future<Order> place(DraftOrder draft, List<ResolvedLine> lines) async {
    if (lines.isEmpty) {
      throw StateError('EMPTY_CART');
    }
    final totals = CartTotals.compute(lines, draft.promoCode);
    final isCod = draft.paymentMethod == PaymentMethod.cod;
    final status = isCod ? OrderStatus.codConfirmed : OrderStatus.pendingPayment;

    final seq = (_box.get('seq', defaultValue: 1000) as int) + 1;
    await _box.put('seq', seq);

    final order = Order(
      orderNo: 'LOOT-$seq',
      email: draft.email,
      phone: draft.phone,
      status: status,
      paymentMethod: draft.paymentMethod,
      lines: [
        for (final l in lines)
          OrderLine(
            sku: l.variant.sku,
            productSlug: l.product.slug,
            productName: l.product.name,
            productNameAr: l.product.nameAr,
            emoji: l.product.emoji,
            tile: l.product.tile,
            unitPriceFils: l.variant.priceFils,
            qty: l.line.qty,
          ),
      ],
      address: draft.address,
      subtotalFils: totals.subtotal.fils,
      shippingFils: totals.shipping.fils,
      discountFils: totals.discount.fils,
      totalFils: totals.total.fils,
      placedAt: DateTime.now(),
      events: [
        OrderEvent(status: status, at: DateTime.now(), note: 'Order placed'),
      ],
    );

    await _box.put(order.orderNo, order.toJson());
    return order;
  }

  @override
  Future<Order?> confirmPayment(String orderNo, {required bool success}) async {
    final order = await _read(orderNo);
    if (order == null || order.status != OrderStatus.pendingPayment) {
      return order; // idempotent, like the real webhook
    }
    final updated = success
        ? order.copyWith(
            status: OrderStatus.paid,
            events: [
              ...order.events,
              OrderEvent(
                  status: OrderStatus.paid,
                  at: DateTime.now(),
                  note: 'KNET payment received (sandbox)'),
            ],
          )
        : order; // failed attempts leave the order pending, like the webhook
    await _box.put(orderNo, updated.toJson());
    return updated;
  }

  @override
  Future<List<Order>> recentOrders() async {
    final orders = <Order>[];
    for (final key in _box.keys) {
      if (key is String && key.startsWith('LOOT-')) {
        final order = await _read(key);
        if (order != null) orders.add(order);
      }
    }
    orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return orders;
  }

  @override
  Future<Order?> byNumberAndPhone(String orderNo, String phone) async {
    final order = await _read(orderNo.trim().toUpperCase());
    if (order == null) return null;
    String digits(String s) => s.replaceAll(RegExp(r'\D'), '');
    final query = digits(phone).replaceFirst(RegExp('^965'), '');
    return query.isNotEmpty && digits(order.phone).endsWith(query)
        ? order
        : null;
  }

  Future<Order?> _read(String orderNo) async {
    final raw = _box.get(orderNo);
    if (raw == null) return null;
    return Order.fromJson(Map<dynamic, dynamic>.from(raw as Map));
  }
}
