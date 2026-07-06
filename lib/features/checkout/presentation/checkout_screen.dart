import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../cart/presentation/cart_providers.dart';
import '../domain/order.dart';
import 'checkout_providers.dart';

/// Guest-first checkout, 3 steps on one narrow (560px) trusted surface:
/// contact → Kuwaiti address → payment (KNET first, COD second, card third,
/// Apple Pay disabled slot). Spec §3.2.
///
/// Demo mode mirrors the production flow shape: place order → for KNET/card
/// "redirect" to the sandbox gateway page → result. COD confirms immediately.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _step = 0;
  bool _placing = false;

  // Step 1 — contact
  final _contactKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  // Step 2 — address
  final _addressKey = GlobalKey<FormState>();
  String? _governorate;
  final _area = TextEditingController();
  final _block = TextEditingController();
  final _street = TextEditingController();
  final _building = TextEditingController();
  final _floor = TextEditingController();
  final _apartment = TextEditingController();
  final _directions = TextEditingController();

  // Step 3 — payment
  PaymentMethod _method = PaymentMethod.knet;

  @override
  void dispose() {
    for (final c in [
      _email, _phone, _area, _block, _street, _building,
      _floor, _apartment, _directions,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppPalette.white, // trusted surface
      appBar: AppBar(
        backgroundColor: AppPalette.white,
        title: Text(l10n.checkoutTitle),
        leading: BackButton(onPressed: () {
          if (_step > 0) {
            setState(() => _step--);
          } else {
            context.pop();
          }
        }),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.all(Gap.lg),
          children: [
            ContentClamp(
              maxWidth: Layout.checkoutMaxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepIndicator(current: _step),
                  const SizedBox(height: Gap.xl),
                  switch (_step) {
                    0 => _contactStep(l10n),
                    1 => _addressStep(l10n),
                    _ => _paymentStep(l10n),
                  },
                  const SizedBox(height: Gap.xl),
                  const TrustFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactStep(AppLocalizations l10n) {
    return Form(
      key: _contactKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.stepContact, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: Gap.lg),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: l10n.email),
            validator: (v) => v != null && RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)
                ? null
                : l10n.invalidEmail,
          ),
          const SizedBox(height: Gap.lg),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            decoration: InputDecoration(labelText: l10n.phone, prefixText: '+965 '),
            validator: (v) {
              final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
              return digits.length == 8 ? null : l10n.invalidPhone;
            },
          ),
          const SizedBox(height: Gap.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_contactKey.currentState!.validate()) {
                  setState(() => _step = 1);
                }
              },
              child: Text(l10n.continueBtn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressStep(AppLocalizations l10n) {
    final isAr = context.isArabic;
    return Form(
      key: _addressKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.stepAddress, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: Gap.lg),
          DropdownButtonFormField<String>(
            initialValue: _governorate,
            decoration: InputDecoration(labelText: l10n.governorate),
            items: [
              for (final (en, ar) in kuwaitGovernorates)
                DropdownMenuItem(value: en, child: Text(isAr ? ar : en)),
            ],
            onChanged: (v) => setState(() => _governorate = v),
            validator: (v) => v == null ? l10n.requiredField : null,
          ),
          const SizedBox(height: Gap.lg),
          TextFormField(
            controller: _area,
            decoration: InputDecoration(labelText: l10n.area),
            validator: _required,
          ),
          const SizedBox(height: Gap.lg),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _block,
                  decoration: InputDecoration(labelText: l10n.block),
                  validator: _required,
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: TextFormField(
                  controller: _street,
                  decoration: InputDecoration(labelText: l10n.street),
                  validator: _required,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _building,
                  decoration: InputDecoration(labelText: l10n.building),
                  validator: _required,
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: TextFormField(
                  controller: _floor,
                  decoration: InputDecoration(
                      labelText: '${l10n.floorField} (${l10n.optional})'),
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: TextFormField(
                  controller: _apartment,
                  decoration: InputDecoration(
                      labelText: '${l10n.apartment} (${l10n.optional})'),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          TextFormField(
            controller: _directions,
            maxLines: 2,
            decoration: InputDecoration(
                labelText: '${l10n.directions} (${l10n.optional})'),
          ),
          const SizedBox(height: Gap.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (_addressKey.currentState!.validate()) {
                  setState(() => _step = 2);
                }
              },
              child: Text(l10n.continueBtn),
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? context.l10n.requiredField : null;

  Widget _paymentStep(AppLocalizations l10n) {
    final lang = context.isArabic ? 'ar' : 'en';
    final totals = ref.watch(cartTotalsProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.paymentMethod, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: Gap.lg),
        // KNET first — ~70% of Kuwaiti online payments. COD second: a
        // conversion requirement, not an afterthought (spec §2.4).
        _PayOption(
          selected: _method == PaymentMethod.knet,
          onTap: () => setState(() => _method = PaymentMethod.knet),
          icon: Icons.credit_card_rounded,
          title: l10n.payKnet,
          subtitle: l10n.payKnetDesc,
        ),
        _PayOption(
          selected: _method == PaymentMethod.cod,
          onTap: () => setState(() => _method = PaymentMethod.cod),
          icon: Icons.payments_outlined,
          title: l10n.payCod,
          subtitle: l10n.payCodDesc,
        ),
        _PayOption(
          selected: _method == PaymentMethod.card,
          onTap: () => setState(() => _method = PaymentMethod.card),
          icon: Icons.credit_score_rounded,
          title: l10n.payCard,
          subtitle: l10n.payCardDesc,
        ),
        _PayOption(
          selected: false,
          onTap: null, // Phase 2 slot — built in, not wired (spec §5.1)
          icon: Icons.phone_iphone_rounded,
          title: l10n.payApplePay,
          subtitle: l10n.phase2Tag,
        ),
        const SizedBox(height: Gap.xl),
        const _SummaryCard(),
        const SizedBox(height: Gap.xl),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _placing ? null : _placeOrder,
            child: _placing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppPalette.white),
                  )
                : Text(
                    _method == PaymentMethod.cod || totals == null
                        ? l10n.placeOrder
                        : l10n.payNow(totals.total.format(lang)),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    try {
      final lines = await ref.read(resolvedCartProvider.future);
      final promo = ref.read(cartProvider).promoCode;
      final draft = DraftOrder(
        email: _email.text.trim(),
        phone: '+965${_phone.text.replaceAll(RegExp(r'\D'), '')}',
        paymentMethod: _method,
        promoCode: promo,
        address: KuwaitAddress(
          governorate: _governorate!,
          area: _area.text.trim(),
          block: _block.text.trim(),
          street: _street.text.trim(),
          building: _building.text.trim(),
          floor: _floor.text.trim().isEmpty ? null : _floor.text.trim(),
          apartment:
              _apartment.text.trim().isEmpty ? null : _apartment.text.trim(),
          directions:
              _directions.text.trim().isEmpty ? null : _directions.text.trim(),
        ),
      );
      final order =
          await ref.read(orderRepositoryProvider).place(draft, lines);
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      if (order.paymentMethod == PaymentMethod.cod) {
        context.go('/checkout/result?order=${order.orderNo}');
      } else {
        // Production: redirect to the MyFatoorah hosted page. Demo: the
        // sandbox gateway screen plays that role.
        context.go('/checkout/pay?order=${order.orderNo}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [l10n.stepContact, l10n.stepAddress, l10n.stepPayment];
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsetsDirectional.symmetric(horizontal: Gap.sm),
                color: i <= current ? AppPalette.teal : AppPalette.hairline,
              ),
            ),
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= current ? AppPalette.teal : AppPalette.hairline,
                ),
                child: i < current
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: AppPalette.white)
                    : Text(
                        '${i + 1}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: i <= current
                                  ? AppPalette.white
                                  : AppPalette.inkMuted,
                            ),
                      ),
              ),
              const SizedBox(height: Gap.xs),
              Text(labels[i], style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ],
    );
  }
}

class _PayOption extends StatelessWidget {
  const _PayOption({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final bool selected;
  final VoidCallback? onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: Gap.md),
      child: Material(
        color: selected ? AppPalette.sky : AppPalette.white,
        borderRadius: Corners.chipRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: Corners.chipRadius,
          child: Container(
            padding: const EdgeInsetsDirectional.all(Gap.lg),
            decoration: BoxDecoration(
              borderRadius: Corners.chipRadius,
              border: Border.all(
                color: selected ? AppPalette.teal : AppPalette.hairline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: disabled ? AppPalette.inkMuted : AppPalette.teal),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color:
                                  disabled ? AppPalette.inkMuted : AppPalette.ink,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppPalette.inkMuted),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppPalette.teal),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = context.isArabic ? 'ar' : 'en';
    final lines = ref.watch(resolvedCartProvider).valueOrNull ?? [];
    final totals = ref.watch(cartTotalsProvider).valueOrNull;

    return Container(
      padding: const EdgeInsetsDirectional.all(Gap.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppPalette.hairline),
        borderRadius: Corners.chipRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.orderSummary, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Gap.md),
          for (final line in lines)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: Gap.xs),
              child: Row(
                children: [
                  Text('${line.line.qty}×',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppPalette.inkMuted)),
                  const SizedBox(width: Gap.sm),
                  Expanded(
                    child: Text(
                      context.isArabic ? line.product.nameAr : line.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(line.lineTotal.format(lang),
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          if (totals != null) ...[
            const Divider(height: Gap.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.total, style: Theme.of(context).textTheme.titleMedium),
                Text(totals.total.format(lang),
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
