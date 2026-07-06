import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';

/// Auth screen built with three slots from day one (spec §2.3): email,
/// Google, Apple. In demo mode the providers are visible but disabled with an
/// explanatory note — they activate when Supabase Auth is connected. Apple is
/// tagged Phase 2 (App Store Guideline 4.8 obligation before submission).
/// Guest continuation is emphasized (Guideline 5.1.1: no forced registration).
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: AppBar(backgroundColor: AppPalette.white),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(Gap.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('🧸', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 56)),
                  const SizedBox(height: Gap.lg),
                  Text(l10n.signInTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: Gap.sm),
                  Text(
                    l10n.signInSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppPalette.inkMuted),
                  ),
                  const SizedBox(height: Gap.xxl),
                  _AuthSlot(
                    icon: Icons.mail_outline_rounded,
                    label: l10n.signInEmail,
                  ),
                  const SizedBox(height: Gap.md),
                  _AuthSlot(
                    icon: Icons.g_mobiledata_rounded,
                    label: l10n.signInGoogle,
                  ),
                  const SizedBox(height: Gap.md),
                  _AuthSlot(
                    icon: Icons.apple_rounded,
                    label: l10n.signInApple,
                    tag: l10n.phase2Tag,
                  ),
                  const SizedBox(height: Gap.lg),
                  Container(
                    padding: const EdgeInsetsDirectional.all(Gap.md),
                    decoration: BoxDecoration(
                      color: AppPalette.sky,
                      borderRadius: Corners.chipRadius,
                    ),
                    child: Text(
                      l10n.demoModeNote,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppPalette.inkMuted),
                    ),
                  ),
                  const SizedBox(height: Gap.xl),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: Text(l10n.continueAsGuest),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthSlot extends StatelessWidget {
  const _AuthSlot({required this.icon, required this.label, this.tag});

  final IconData icon;
  final String label;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: null, // enabled when Supabase Auth is configured
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: AppPalette.hairline),
      ),
      icon: Icon(icon, color: AppPalette.inkMuted),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppPalette.inkMuted)),
          if (tag != null) ...[
            const SizedBox(width: Gap.sm),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: Gap.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppPalette.sunshine,
                borderRadius: Corners.chipRadius,
              ),
              child: Text(tag!,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppPalette.ink)),
            ),
          ],
        ],
      ),
    );
  }
}
