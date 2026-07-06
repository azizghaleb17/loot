import 'package:flutter/widgets.dart';

/// Spacing — 4-pt base grid (spec §3.1).
abstract final class Gap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radii.
abstract final class Corners {
  /// Playful cards (age cards, promo banners).
  static const double playful = 24;

  /// Product cards.
  static const double card = 16;

  /// Buttons and inputs on playful surfaces.
  static const double button = 12;

  /// Chips — and checkout inputs (sharper = more serious).
  static const double chip = 8;

  static BorderRadius get playfulRadius => BorderRadius.circular(playful);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get buttonRadius => BorderRadius.circular(button);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
}

/// Layout breakpoints and clamps (spec §3.3).
abstract final class Layout {
  static const double phoneMax = 600;
  static const double desktopMin = 1024;

  /// Global content clamp, centered on cream canvas.
  static const double contentMaxWidth = 1200;

  /// Checkout always clamps narrow — reads as trustworthy on desktop.
  static const double checkoutMaxWidth = 560;

  /// Product grid tile sizing — columns derive from width, never fixed counts.
  static const double gridMaxTileWidth = 240;

  static bool isPhone(double width) => width < phoneMax;
  static bool isDesktop(double width) => width >= desktopMin;
}
