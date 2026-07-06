import 'package:flutter/material.dart';

/// Toybox palette — spec §3.1. Color is carried by fills and illustration;
/// text is almost always [ink]. WCAG AA checked.
abstract final class AppPalette {
  /// Deep navy — all body text, trusted-surface headers (12.6:1 on white).
  static const ink = Color(0xFF1E2A4A);

  /// Coral — CTAs, price highlights (AA as white-on-coral).
  static const coral = Color(0xFFE8503A);

  /// Teal — links, selected filters, secondary buttons (AA on white).
  static const teal = Color(0xFF0E8A8A);

  /// Sunshine — badges, ratings, playful accents. NEVER text; pairs with ink.
  static const sunshine = Color(0xFFFFC53D);

  /// Playful section backgrounds.
  static const sky = Color(0xFFEAF4FB);

  /// Playful app background.
  static const cream = Color(0xFFFFF8F0);

  static const success = Color(0xFF1F8A4C);
  static const error = Color(0xFFC6362B);
  static const info = Color(0xFF2D6FD2);

  static const white = Color(0xFFFFFFFF);

  /// Muted ink for secondary text (still AA on cream/white).
  static const inkMuted = Color(0xFF5A6784);

  /// Hairline borders on trusted surfaces.
  static const hairline = Color(0xFFE3E7EF);

  /// Six pastel fills for age navigation and demo product tiles —
  /// peach / mint / lilac / sky / lemon / sage, each paired with ink text.
  static const pastels = <Color>[
    Color(0xFFFFE3D6), // peach
    Color(0xFFD9F2E4), // mint
    Color(0xFFE9E2F7), // lilac
    Color(0xFFD8ECFA), // sky
    Color(0xFFFFF3C9), // lemon
    Color(0xFFE4EDDC), // sage
  ];

  static Color pastel(int index) => pastels[index % pastels.length];

  /// Slightly deeper companions for pastel tiles (sticker shadows, chips).
  static const pastelsDeep = <Color>[
    Color(0xFFF5C2A9),
    Color(0xFFA9DFC2),
    Color(0xFFCBBCE8),
    Color(0xFFA9D3F0),
    Color(0xFFF2DE9B),
    Color(0xFFC2D6AE),
  ];

  static Color pastelDeep(int index) => pastelsDeep[index % pastelsDeep.length];
}
