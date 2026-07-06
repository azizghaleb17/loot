import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../domain/order.dart';
import 'checkout_providers.dart';

/// Payment-gateway return URL (`/checkout/result?order=…`). Confirms COD and
/// paid orders; failed payments offer retry (order stays pending, like the
/// real webhook flow). Guests get a create-account prompt (spec §2.3).
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.orderNo, required this.failed});

  final String orderNo;
  final bool failed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = context.isArabic ? 'ar' : 'en';
    final orderAsync = ref.watch(orderByNoProvider(orderNo));

    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: AppBar(
        backgroundColor: AppPalette.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: orderAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              ErrorView(onRetry: () => ref.invalidate(orderByNoProvider(orderNo))),
          data: (order) {
            if (order == null) {
              return EmptyState(
                emoji: '🔍',
                title: l10n.orderNotFound,
                hint: '',
                actionLabel: l10n.continueShopping,
                onAction: () => context.go('/'),
              );
            }
            if (failed) {
              return _Body(
                emoji: '😕',
                title: l10n.paymentFailedTitle,
                body: l10n.paymentFailedBody,
                orderNo: order.orderNo,
                primaryLabel: l10n.tryAgain,
                onPrimary: () =>
                    context.go('/checkout/pay?order=${order.orderNo}'),
              );
            }
            final isCod = order.paymentMethod == PaymentMethod.cod;
            return _Body(
              emoji: '🎉',
              title: isCod ? l10n.codSuccessTitle : l10n.paymentSuccessTitle,
              body: isCod
                  ? l10n.codSuccessBody(order.total.format(lang))
                  : l10n.paymentSuccessBody,
              orderNo: order.orderNo,
              primaryLabel: l10n.trackOrder,
              onPrimary: () => context.go('/orders/${order.orderNo}'),
              showAccountPrompt: true,
            );
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.emoji,
    required this.title,
    required this.body,
    required this.orderNo,
    required this.primaryLabel,
    required this.onPrimary,
    this.showAccountPrompt = false,
  });

  final String emoji;
  final String title;
  final String body;
  final String orderNo;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool showAccountPrompt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(Gap.xl),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: Layout.checkoutMaxWidth),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: Gap.lg),
              Text(title,
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: Gap.sm),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppPalette.inkMuted),
              ),
              const SizedBox(height: Gap.xl),
              Container(
                padding: const EdgeInsetsDirectional.all(Gap.lg),
                decoration: BoxDecoration(
                  color: AppPalette.sky,
                  borderRadius: Corners.chipRadius,
                ),
                child: Column(
                  children: [
                    Text(l10n.orderNumber,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppPalette.inkMuted)),
                    Text(orderNo,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),
              const SizedBox(height: Gap.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                    onPressed: onPrimary, child: Text(primaryLabel)),
              ),
              const SizedBox(height: Gap.md),
              TextButton(
                onPressed: () => context.go('/'),
                child: Text(l10n.continueShopping),
              ),
              if (showAccountPrompt) ...[
                const Divider(height: Gap.xxl),
                Text(
                  l10n.createAccountPrompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppPalette.inkMuted),
                ),
                const SizedBox(height: Gap.sm),
                OutlinedButton(
                  onPressed: () => context.push('/signin'),
                  child: Text(l10n.createAccountCta),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
