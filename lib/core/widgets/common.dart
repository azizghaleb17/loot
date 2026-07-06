import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n.dart';
import '../theme/palette.dart';
import '../theme/tokens.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.count});

  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sale/ratings sunshine is decorative fill — the numeric value carries
        // the information (never color-only signaling).
        const Icon(Icons.star_rounded, size: 16, color: AppPalette.sunshine),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        if (count != null) ...[
          const SizedBox(width: 2),
          Text(
            context.l10n.ratingCount(count!),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppPalette.inkMuted),
          ),
        ],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: Gap.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text(context.l10n.seeAll)),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.hint,
    this.actionLabel,
    this.onAction,
  });

  final String emoji;
  final String title;
  final String hint;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(Gap.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(Gap.xl),
              decoration: const BoxDecoration(
                color: AppPalette.sky,
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 44)),
            ),
            const SizedBox(height: Gap.lg),
            Text(title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: Gap.sm),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppPalette.inkMuted),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: Gap.xl),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '🧩',
      title: context.l10n.errorGeneric,
      hint: '',
      actionLabel: context.l10n.retry,
      onAction: onRetry,
    );
  }
}

class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.qty,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  final int qty;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppPalette.hairline),
        borderRadius: Corners.buttonRadius,
        color: AppPalette.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: Icons.remove_rounded,
            enabled: qty > min,
            onTap: () => onChanged(qty - 1),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36),
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ),
          _StepBtn(
            icon: Icons.add_rounded,
            enabled: qty < max,
            onTap: () => onChanged(qty + 1),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 20),
      color: AppPalette.teal,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }
}

/// Clamps content to [Layout.contentMaxWidth] (or a custom width), centered.
class ContentClamp extends StatelessWidget {
  const ContentClamp({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? Layout.contentMaxWidth),
        child: child,
      ),
    );
  }
}

/// Responsive product grid — column count derives from tile width, never fixed.
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: Layout.gridMaxTileWidth,
        mainAxisSpacing: Gap.lg,
        crossAxisSpacing: Gap.lg,
        childAspectRatio: 0.62,
      ),
      itemCount: children.length,
      itemBuilder: (context, i) => children[i],
    );
  }
}

/// Trust row for cart/checkout — payment marks + secure copy (trusted mode).
class TrustFooter extends StatelessWidget {
  const TrustFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 16, color: AppPalette.inkMuted),
        const SizedBox(width: Gap.sm),
        Flexible(
          child: Text(
            context.l10n.trustRow,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppPalette.inkMuted),
          ),
        ),
      ],
    );
  }
}

/// Age card for the home rail and age hub headers.
class AgeCard extends StatelessWidget {
  const AgeCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.tile,
    required this.ageSlug,
    this.compact = false,
  });

  final String emoji;
  final String label;
  final int tile;
  final String ageSlug;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.pastel(tile),
      borderRadius: Corners.playfulRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/age/$ageSlug'),
        child: Padding(
          padding: EdgeInsetsDirectional.all(compact ? Gap.md : Gap.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: compact ? 28 : 36)),
              const SizedBox(height: Gap.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: AppPalette.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
