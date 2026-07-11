import 'package:flutter/material.dart';

import '../theme/palette.dart';
import '../theme/tokens.dart';

/// Shimmer sweep over skeleton shapes — shown while async content loads so
/// screens paint their final layout immediately instead of a spinner flash.
/// Respects `disableAnimations` (static skeletons, no sweep).
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            AppPalette.ink.withValues(alpha: 0.05),
            AppPalette.ink.withValues(alpha: 0.10),
            AppPalette.ink.withValues(alpha: 0.05),
          ],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlidingGradient(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.percent);

  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (percent * 3 - 1.5), 0, 0);
}

/// One grey placeholder shape.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = Corners.chip,
    this.square = false,
  });

  final double? width;
  final double? height;
  final double radius;
  final bool square; // true = keep 1:1 aspect (image tiles)

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppPalette.ink.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    return square ? AspectRatio(aspectRatio: 1, child: box) : box;
  }
}

/// Mirrors ProductCard's layout so the grid doesn't shift when data lands.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(Gap.sm),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: Corners.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(square: true, radius: Corners.card),
          const SizedBox(height: Gap.md),
          Padding(
            padding:
                const EdgeInsetsDirectional.symmetric(horizontal: Gap.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 64, height: 10),
                SizedBox(height: Gap.sm),
                SkeletonBox(width: 140, height: 14),
                SizedBox(height: Gap.sm),
                SkeletonBox(width: 90, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal shelf of card skeletons (home shelves).
class ShelfSkeleton extends StatelessWidget {
  const ShelfSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SizedBox(
        height: 340,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          separatorBuilder: (_, _) => const SizedBox(width: Gap.lg),
          itemBuilder: (_, _) =>
              const SizedBox(width: 220, child: ProductCardSkeleton()),
        ),
      ),
    );
  }
}

/// Responsive grid of card skeletons (listing/search results).
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: Layout.gridMaxTileWidth,
          mainAxisSpacing: Gap.lg,
          crossAxisSpacing: Gap.lg,
          childAspectRatio: 0.62,
        ),
        itemCount: count,
        itemBuilder: (_, _) => const ProductCardSkeleton(),
      ),
    );
  }
}

/// Skeleton for the home age rail — same responsive shape as _AgeRail.
class AgeRailSkeleton extends StatelessWidget {
  const AgeRailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          if (wide) {
            return Row(
              children: [
                for (var i = 0; i < 6; i++) ...[
                  if (i > 0) const SizedBox(width: Gap.md),
                  const Expanded(
                    child: SkeletonBox(height: 118, radius: Corners.playful),
                  ),
                ],
              ],
            );
          }
          return SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(width: Gap.md),
              itemBuilder: (_, _) => const SkeletonBox(
                  width: 120, height: 128, radius: Corners.playful),
            ),
          );
        },
      ),
    );
  }
}

/// Product detail page skeleton — gallery pane + buy-box lines.
class ProductPageSkeleton extends StatelessWidget {
  const ProductPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final twoPane = Layout.isDesktop(MediaQuery.sizeOf(context).width);
    const gallery = SkeletonBox(square: true, radius: Corners.playful);
    final buyBox = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SkeletonBox(width: 90, height: 14),
        SizedBox(height: Gap.md),
        SkeletonBox(width: 280, height: 28),
        SizedBox(height: Gap.md),
        SkeletonBox(width: 160, height: 16),
        SizedBox(height: Gap.lg),
        SkeletonBox(width: 120, height: 24),
        SizedBox(height: Gap.xl),
        SkeletonBox(height: 52, radius: Corners.button),
      ],
    );

    return Shimmer(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(Gap.lg),
        child: twoPane
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 5, child: gallery),
                  const SizedBox(width: Gap.xxl),
                  Expanded(flex: 5, child: buyBox),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [gallery, const SizedBox(height: Gap.lg), buyBox],
              ),
      ),
    );
  }
}
