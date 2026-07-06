import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Demo imagery signature: an emoji "sticker" on a pastel tile with a soft
/// tinted shadow and a slight playful rotation. Swaps to real product
/// photography (Supabase Storage) without touching call sites — the tile
/// stays as the loading/fallback frame.
class StickerTile extends StatelessWidget {
  const StickerTile({
    super.key,
    required this.emoji,
    required this.tile,
    this.size,
    this.borderRadius,
    this.rotated = true,
  });

  final String emoji;
  final int tile;
  final double? size;
  final BorderRadius? borderRadius;
  final bool rotated;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.pastel(tile),
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
        child: Center(
          child: Transform.rotate(
            angle: rotated ? -0.08 : 0,
            child: Container(
              padding: const EdgeInsetsDirectional.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.pastelDeep(tile).withValues(alpha: 0.6),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                emoji,
                style: TextStyle(fontSize: size ?? 44, height: 1.2),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
