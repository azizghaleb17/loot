import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/price_text.dart';
import '../../../core/widgets/sticker_tile.dart';
import '../domain/cart.dart';
import 'cart_providers.dart';

/// Cart — first trusted-mode screen: white surfaces, ink text, coral only on
/// the single primary action (spec §3.1).
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final resolved = ref.watch(resolvedCartProvider);

    return SafeArea(
      child: resolved.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            ErrorView(onRetry: () => ref.invalidate(resolvedCartProvider)),
        data: (lines) {
          if (lines.isEmpty) {
            return EmptyState(
              emoji: '🧺',
              title: l10n.cartEmpty,
              hint: l10n.cartEmptyHint,
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
                    Text(l10n.cartTitle,
                        style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: Gap.lg),
                    for (final line in lines) _CartLineTile(line: line),
                    const SizedBox(height: Gap.lg),
                    const _PromoField(),
                    const SizedBox(height: Gap.lg),
                    const _TotalsCard(),
                    const SizedBox(height: Gap.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.push('/checkout'),
                        child: Text(l10n.goToCheckout),
                      ),
                    ),
                    const SizedBox(height: Gap.md),
                    const TrustFooter(),
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
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line});

  final ResolvedLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isAr = context.isArabic;
    final name = isAr ? line.product.nameAr : line.product.name;

    return Dismissible(
      key: ValueKey(line.variant.sku),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: Gap.xl),
        decoration: BoxDecoration(
          color: AppPalette.error,
          borderRadius: Corners.cardRadius,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppPalette.white),
      ),
      onDismissed: (_) {
        final removed = ref.read(cartProvider.notifier).remove(line.variant.sku);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.itemRemoved(name)),
            action: removed == null
                ? null
                : SnackBarAction(
                    label: l10n.undo,
                    textColor: AppPalette.sunshine,
                    onPressed: () =>
                        ref.read(cartProvider.notifier).restore(removed),
                  ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: Gap.md),
        padding: const EdgeInsetsDirectional.all(Gap.md),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: Corners.cardRadius,
          border: Border.all(color: AppPalette.hairline),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: InkWell(
                onTap: () => context.push('/p/${line.product.slug}'),
                child: StickerTile(
                  emoji: line.product.emoji,
                  tile: line.product.tile,
                  size: 24,
                  rotated: false,
                ),
              ),
            ),
            const SizedBox(width: Gap.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall),
                  if (line.variant.name.isNotEmpty)
                    Text(
                      isAr ? line.variant.nameAr : line.variant.name,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppPalette.inkMuted),
                    ),
                  const SizedBox(height: Gap.sm),
                  QtyStepper(
                    qty: line.line.qty,
                    max: line.variant.stockQty,
                    onChanged: (q) => ref
                        .read(cartProvider.notifier)
                        .setQty(line.variant.sku, q),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Gap.md),
            PriceText(price: line.lineTotal),
          ],
        ),
      ),
    );
  }
}

class _PromoField extends ConsumerStatefulWidget {
  const _PromoField();

  @override
  ConsumerState<_PromoField> createState() => _PromoFieldState();
}

class _PromoFieldState extends ConsumerState<_PromoField> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Driven by computed totals, not the stored code — "applied" only shows
    // when the discount is actually in effect (e.g. min order still met).
    final applied =
        ref.watch(cartTotalsProvider).valueOrNull?.promoApplied;

    if (applied != null) {
      return Row(
        children: [
          const Icon(Icons.local_offer_outlined,
              size: 18, color: AppPalette.success),
          const SizedBox(width: Gap.sm),
          Text(
            l10n.promoApplied(applied.code),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppPalette.success),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () => ref.read(cartProvider.notifier).clearPromo(),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration:
                InputDecoration(hintText: l10n.promoCode, errorText: _error),
            onSubmitted: (_) => _apply(),
          ),
        ),
        const SizedBox(width: Gap.sm),
        SizedBox(
          height: 48,
          child: OutlinedButton(
              onPressed: _apply, child: Text(l10n.promoApply)),
        ),
      ],
    );
  }

  Future<void> _apply() async {
    final totals = await ref.read(cartTotalsProvider.future);
    final ok = ref
        .read(cartProvider.notifier)
        .applyPromo(_controller.text, totals.subtotal);
    if (mounted) {
      setState(() => _error = ok ? null : context.l10n.promoInvalid);
    }
  }
}

class _TotalsCard extends ConsumerWidget {
  const _TotalsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = context.isArabic ? 'ar' : 'en';
    final totals = ref.watch(cartTotalsProvider);

    return totals.maybeWhen(
      data: (t) => Container(
        padding: const EdgeInsetsDirectional.all(Gap.lg),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: Corners.cardRadius,
          border: Border.all(color: AppPalette.hairline),
        ),
        child: Column(
          children: [
            _row(context, l10n.subtotal, t.subtotal.format(lang)),
            if (!t.discount.isZero)
              _row(context, l10n.discount, '− ${t.discount.format(lang)}',
                  color: AppPalette.success),
            _row(
              context,
              l10n.shipping,
              t.shipping.isZero ? l10n.freeShipping : t.shipping.format(lang),
              color: t.shipping.isZero ? AppPalette.success : null,
            ),
            const Divider(height: Gap.xl),
            _row(context, l10n.total, t.total.format(lang), bold: true),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool bold = false, Color? color}) {
    final style = bold
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyLarge?.copyWith(color: color);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: Gap.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value,
              style: style?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
