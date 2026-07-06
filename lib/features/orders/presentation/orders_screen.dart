import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../checkout/domain/order.dart';
import '../../checkout/presentation/checkout_providers.dart';

String orderStatusLabel(BuildContext context, OrderStatus status) {
  final l10n = context.l10n;
  return switch (status) {
    OrderStatus.pendingPayment => l10n.statusPendingPayment,
    OrderStatus.paid => l10n.statusPaid,
    OrderStatus.codConfirmed => l10n.statusCodConfirmed,
    OrderStatus.processing => l10n.statusProcessing,
    OrderStatus.shipped => l10n.statusShipped,
    OrderStatus.delivered => l10n.statusDelivered,
    OrderStatus.cancelled => l10n.statusCancelled,
    OrderStatus.refunded => l10n.statusRefunded,
  };
}

Color orderStatusColor(OrderStatus status) => switch (status) {
      // Dark amber, not sunshine — sunshine is never used as text (spec §3.1).
      OrderStatus.pendingPayment => const Color(0xFFA36A00),
      OrderStatus.paid ||
      OrderStatus.codConfirmed ||
      OrderStatus.delivered =>
        AppPalette.success,
      OrderStatus.processing || OrderStatus.shipped => AppPalette.info,
      OrderStatus.cancelled || OrderStatus.refunded => AppPalette.error,
    };

/// Order history (device-local in demo mode) + guest order lookup entry.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final orders = ref.watch(recentOrdersProvider);

    return SafeArea(
      child: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            ErrorView(onRetry: () => ref.invalidate(recentOrdersProvider)),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              emoji: '📦',
              title: l10n.ordersEmpty,
              hint: l10n.ordersEmptyHint,
              actionLabel: l10n.startShopping,
              onAction: () => context.go('/'),
            );
          }
          return ListView(
            padding: const EdgeInsetsDirectional.all(Gap.lg),
            children: [
              ContentClamp(
                maxWidth: 840,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.ordersTitle,
                        style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: Gap.lg),
                    for (final order in items) _OrderCard(order: order),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = context.isArabic ? 'ar' : 'en';
    final date = DateFormat.yMMMd(lang).format(order.placedAt);

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: Gap.md),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: Corners.cardRadius,
        border: Border.all(color: AppPalette.hairline),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: Corners.cardRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/orders/${order.orderNo}'),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(Gap.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.orderNo,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        l10n.placedOn(date),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppPalette.inkMuted),
                      ),
                      const SizedBox(height: Gap.sm),
                      _StatusPill(status: order.status),
                    ],
                  ),
                ),
                Text(order.total.format(lang),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: Gap.sm),
                const Icon(Icons.chevron_right_rounded,
                    color: AppPalette.inkMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = orderStatusColor(status);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
          horizontal: Gap.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: Corners.chipRadius,
      ),
      child: Text(
        orderStatusLabel(context, status),
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
