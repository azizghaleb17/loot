import 'package:flutter/foundation.dart';

/// KWD money. 1 KWD = 1,000 fils — three decimal places, always.
/// The only place in the codebase that formats currency. Never use doubles.
@immutable
class Money implements Comparable<Money> {
  const Money(this.fils) : assert(fils >= 0, 'Money cannot be negative');

  final int fils;

  static const zero = Money(0);

  /// Parses a KWD decimal string like "7.5", "7.500", "12", "1,250.750".
  factory Money.fromKwd(String input) {
    final cleaned = input.replaceAll(',', '').trim();
    final match = RegExp(r'^(\d+)(?:\.(\d{1,3}))?$').firstMatch(cleaned);
    if (match == null) {
      throw FormatException('Not a KWD amount: $input');
    }
    final whole = int.parse(match.group(1)!);
    final frac = (match.group(2) ?? '').padRight(3, '0');
    return Money(whole * 1000 + int.parse(frac));
  }

  Money operator +(Money other) => Money(fils + other.fils);
  Money operator -(Money other) => Money(fils - other.fils);
  Money operator *(int qty) => Money(fils * qty);
  bool operator >(Money other) => fils > other.fils;
  bool operator <(Money other) => fils < other.fils;
  bool operator >=(Money other) => fils >= other.fils;
  bool operator <=(Money other) => fils <= other.fils;

  /// Percentage discount, truncated to whole fils (matches `place_order` SQL).
  Money percent(int p) => Money((fils * p) ~/ 100);

  bool get isZero => fils == 0;

  /// "7.500" — Western numerals with thousands separators, always 3 dp.
  /// Kuwaiti e-commerce convention: numerals stay Western in Arabic too.
  String get amountText {
    final whole = fils ~/ 1000;
    final frac = (fils % 1000).toString().padLeft(3, '0');
    final digits = whole.toString();
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return '$buf.$frac';
  }

  /// "KD 7.500" / "د.ك 7.500" depending on locale.
  String format(String languageCode) =>
      languageCode == 'ar' ? 'د.ك $amountText' : 'KD $amountText';

  @override
  int compareTo(Money other) => fils.compareTo(other.fils);

  @override
  bool operator ==(Object other) => other is Money && other.fils == fils;

  @override
  int get hashCode => fils.hashCode;

  @override
  String toString() => 'Money($amountText KD)';
}
