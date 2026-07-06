import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/sticker_tile.dart';
import '../../checkout/domain/order.dart';
import '../../checkout/presentation/checkout_providers.dart';
import 'orders_screen.dart';

/// Order tracking: status timeline from order events + line items + address.
/// Also the target of guest lookup (spec §3.2).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderNo});

  final String orderNo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = context.isArabic ? 'ar' : 'en';
    final orderAsync = ref.watch(orderByNoProvider(orderNo));

    return SafeArea(
      child: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            ErrorView(onRetry: () => ref.invalidate(orderByNoProvider(orderNo))),
        data: (order) {
          if (order == null) {
            return EmptyState(
              emoji: '🔍',
              title: l10n.orderNotFound,
              hint: l10n.orderLookupHint,
              actionLabel: l10n.ordersTitle,
              onAction: () => context.go('/orders'),
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
                    Row(
                      children: [
                        BackButton(onPressed: () => context.go('/orders')),
                        Text(order.orderNo,
                            style: Theme.of(context).textTheme.displayMedium),
                      ],
                    ),
                    const SizedBox(height: Gap.lg),
                    _Timeline(order: order),
                    const SizedBox(height: Gap.xl),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final line in order.lines)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                  bottom: Gap.md),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 56,
                                    child: StickerTile(
                                      emoji: line.emoji,
                                      tile: line.tile,
                                      size: 20,
                                      rotated: false,
                                    ),
                                  ),
                                  const SizedBox(width: Gap.md),
                                  Expanded(
                                    child: Text(
                                      context.isArabic
                                          ? line.productNameAr
                                          : line.productName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ),
                                  Text('${line.qty}×',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: AppPalette.inkMuted)),
                                  const SizedBox(width: Gap.sm),
                                  Text(line.lineTotal.format(lang),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall),
                                ],
                              ),
                            ),
                          const Divider(),
                          _totalRow(context, l10n.subtotal,
                              order.subtotal.format(lang)),
                          if (order.discountFils > 0)
                            _totalRow(context, l10n.discount,
                                '− ${order.discount.format(lang)}'),
                          _totalRow(
                              context,
                              l10n.shipping,
                              order.shippingFils == 0
                                  ? l10n.freeShipping
                                  : order.shipping.format(lang)),
                          _totalRow(context, l10n.total, order.total.format(lang),
                              bold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: Gap.lg),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.deliverTo,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: Gap.xs),
                          Text(order.address.governorate,
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text(order.address.summary,
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: Gap.md),
                          Text(l10n.paymentLabel,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: Gap.xs),
                          Text(
                            switch (order.paymentMethod) {
                              PaymentMethod.knet => l10n.payKnet,
                              PaymentMethod.card => l10n.payCard,
                              PaymentMethod.applePay => l10n.payApplePay,
                              PaymentMethod.cod => l10n.payCod,
                            },
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Gap.xxl),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _totalRow(BuildContext context, String label, String value,
      {bool bold = false}) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(Gap.lg),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: Corners.cardRadius,
        border: Border.all(color: AppPalette.hairline),
      ),
      child: child,
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final lang = context.isArabic ? 'ar' : 'en';
    final events = order.events;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, e) in events.indexed)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Icon(
                        i == events.length - 1
                            ? Icons.radio_button_checked_rounded
                            : Icons.check_circle_rounded,
                        size: 18,
                        color: orderStatusColor(e.status),
                      ),
                      if (i < events.length - 1)
                        const Expanded(
                          child: VerticalDivider(
                              width: 18, color: AppPalette.hairline),
                        ),
                    ],
                  ),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.only(bottom: Gap.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(orderStatusLabel(context, e.status),
                              style: Theme.of(context).textTheme.titleSmall),
                          Text(
                            DateFormat.yMMMd(lang).add_jm().format(e.at),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppPalette.inkMuted),
                          ),
                          if (e.note != null)
                            Text(e.note!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppPalette.inkMuted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
