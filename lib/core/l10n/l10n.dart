import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../gen/l10n/app_localizations.dart';

export '../../gen/l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}

const _settingsBoxName = 'settings';

/// Locale preference, persisted across sessions. `null` = follow system.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = Hive.box(_settingsBoxName).get('locale') as String?;
    return code == null ? null : Locale(code);
  }

  void setLocale(Locale? locale) {
    state = locale;
    Hive.box(_settingsBoxName).put('locale', locale?.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
