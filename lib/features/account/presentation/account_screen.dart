import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../checkout/presentation/checkout_providers.dart';

/// Account (trusted mode): guest state + sign-in entry, language switch,
/// orders, guest order lookup, demo notes. Addresses CRUD arrives with the
/// Supabase backend (profiles are server-side).
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final currentLang = locale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(Gap.lg),
        children: [
          ContentClamp(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.accountTitle,
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: Gap.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.all(Gap.xl),
                  decoration: BoxDecoration(
                    color: AppPalette.sky,
                    borderRadius: Corners.cardRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.guestTitle,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: Gap.xs),
                      Text(l10n.guestHint,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppPalette.inkMuted)),
                      const SizedBox(height: Gap.md),
                      ElevatedButton(
                        onPressed: () => context.push('/signin'),
                        child: Text(l10n.signIn),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.xl),
                // Language switch — instant, persisted.
                Text(l10n.language,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Gap.sm),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'en', label: Text('English')),
                    ButtonSegment(value: 'ar', label: Text('العربية')),
                  ],
                  selected: {currentLang},
                  onSelectionChanged: (s) => ref
                      .read(localeProvider.notifier)
                      .setLocale(Locale(s.first)),
                ),
                const SizedBox(height: Gap.xl),
                _Tile(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.myOrders,
                  onTap: () => context.push('/orders'),
                ),
                _Tile(
                  icon: Icons.travel_explore_outlined,
                  title: l10n.lookupOrder,
                  onTap: () => _openLookup(context, ref),
                ),
                const SizedBox(height: Gap.xl),
                Container(
                  padding: const EdgeInsetsDirectional.all(Gap.lg),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppPalette.hairline),
                    borderRadius: Corners.cardRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.aboutDemo,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: Gap.xs),
                      Text(l10n.aboutDemoBody,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppPalette.inkMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLookup(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final noController = TextEditingController();
    final phoneController = TextEditingController();
    String? error;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppPalette.white,
          title: Text(l10n.orderLookupTitle),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.orderLookupHint,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppPalette.inkMuted)),
                const SizedBox(height: Gap.lg),
                TextField(
                  controller: noController,
                  decoration: InputDecoration(
                      labelText: l10n.orderNumber, hintText: 'LOOT-1001'),
                ),
                const SizedBox(height: Gap.md),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: l10n.phone, errorText: error),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.backBtn),
            ),
            ElevatedButton(
              onPressed: () async {
                final order = await ref
                    .read(orderRepositoryProvider)
                    .byNumberAndPhone(
                        noController.text, phoneController.text);
                if (!context.mounted) return;
                if (order == null) {
                  setState(() => error = l10n.orderNotFound);
                } else {
                  Navigator.of(context).pop();
                  unawaited(context.push('/orders/${order.orderNo}'));
                }
              },
              child: Text(l10n.find),
            ),
          ],
        ),
      ),
    );
    noController.dispose();
    phoneController.dispose();
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: Gap.sm),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: Corners.cardRadius,
        border: Border.all(color: AppPalette.hairline),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppPalette.teal),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing:
            const Icon(Icons.chevron_right_rounded, color: AppPalette.inkMuted),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: Corners.cardRadius),
      ),
    );
  }
}
