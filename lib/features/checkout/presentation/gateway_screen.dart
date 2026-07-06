import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import 'checkout_providers.dart';

/// Sandbox stand-in for the MyFatoorah hosted KNET page. In production the
/// checkout redirects to the real gateway URL returned by the `create-payment`
/// edge function; this screen keeps the redirect → pay → return-URL flow
/// intact so stakeholders exercise the same journey (spec §2.4).
class GatewayScreen extends ConsumerWidget {
  const GatewayScreen({super.key, required this.orderNo});

  final String orderNo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = context.isArabic ? 'ar' : 'en';
    final order = ref.watch(orderByNoProvider(orderNo));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: AppPalette.ink,
        foregroundColor: AppPalette.white,
        title: Text(l10n.gatewayTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppPalette.white)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: order.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) =>
                  ErrorView(onRetry: () => ref.invalidate(orderByNoProvider(orderNo))),
              data: (o) => o == null
                  ? Text(l10n.orderNotFound)
                  : Card(
                      margin: const EdgeInsetsDirectional.all(Gap.lg),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(Gap.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('🏦', textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 40)),
                            const SizedBox(height: Gap.md),
                            Text(
                              l10n.gatewaySandboxNote,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppPalette.inkMuted),
                            ),
                            const SizedBox(height: Gap.xl),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.gatewayAmount,
                                    style:
                                        Theme.of(context).textTheme.titleMedium),
                                Text(o.total.format(lang),
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                            const SizedBox(height: Gap.xl),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPalette.success),
                              onPressed: () async {
                                await ref
                                    .read(orderRepositoryProvider)
                                    .confirmPayment(orderNo, success: true);
                                if (context.mounted) {
                                  context.go('/checkout/result?order=$orderNo');
                                }
                              },
                              child: Text(l10n.gatewayPaySuccess),
                            ),
                            const SizedBox(height: Gap.md),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppPalette.error,
                                side: const BorderSide(color: AppPalette.error),
                              ),
                              onPressed: () async {
                                await ref
                                    .read(orderRepositoryProvider)
                                    .confirmPayment(orderNo, success: false);
                                if (context.mounted) {
                                  context.go(
                                      '/checkout/result?order=$orderNo&failed=1');
                                }
                              },
                              child: Text(l10n.gatewayPayFail),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
