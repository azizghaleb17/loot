import 'package:flutter/material.dart';

import '../theme/palette.dart';
import '../utils/money.dart';

/// The only widget that renders prices. Tabular figures, Western numerals
/// in both locales (Kuwaiti e-commerce convention), optional compare-at
/// strikethrough. Sale price shows in coral + the old price struck through.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.compareAt,
    this.style,
    this.emphasized = false,
  });

  final Money price;
  final Money? compareAt;
  final TextStyle? style;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final base = style ?? Theme.of(context).textTheme.titleMedium!;
    final onSale = compareAt != null && compareAt! > price;
    final priceStyle = base.copyWith(
      color: onSale || emphasized ? AppPalette.coral : AppPalette.ink,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (!onSale) return Text(price.format(lang), style: priceStyle);

    return Row(
      mainAxisSize: MainAxisSize.min,
      textBaseline: TextBaseline.alphabetic,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Text(price.format(lang), style: priceStyle),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            compareAt!.format(lang),
            overflow: TextOverflow.ellipsis,
            style: base.copyWith(
              color: AppPalette.inkMuted,
              decoration: TextDecoration.lineThrough,
              fontSize: (base.fontSize ?? 14) - 2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
