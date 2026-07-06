import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/order_repository.dart';
import '../domain/order.dart';

final orderRepositoryProvider =
    Provider<OrderRepository>((ref) => DemoOrderRepository());

final recentOrdersProvider = FutureProvider.autoDispose<List<Order>>(
  (ref) => ref.watch(orderRepositoryProvider).recentOrders(),
);

final orderByNoProvider = FutureProvider.autoDispose.family<Order?, String>(
  (ref, orderNo) async {
    final orders = await ref.watch(orderRepositoryProvider).recentOrders();
    for (final o in orders) {
      if (o.orderNo == orderNo) return o;
    }
    return null;
  },
);
