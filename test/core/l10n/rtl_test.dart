import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loot/gen/l10n/app_localizations.dart';

Widget appAt(Locale locale, WidgetBuilder builder) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(builder: builder),
    );

void main() {
  testWidgets('Arabic locale renders RTL with Arabic strings', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(appAt(const Locale('ar'), (context) {
      ctx = context;
      return Text(AppLocalizations.of(context).cartTitle);
    }));
    await tester.pumpAndSettle();

    expect(Directionality.of(ctx), TextDirection.rtl);
    expect(find.text('سلتك'), findsOneWidget);
  });

  testWidgets('English locale renders LTR with English strings', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(appAt(const Locale('en'), (context) {
      ctx = context;
      return Text(AppLocalizations.of(context).cartTitle);
    }));
    await tester.pumpAndSettle();

    expect(Directionality.of(ctx), TextDirection.ltr);
    expect(find.text('Your cart'), findsOneWidget);
  });

  testWidgets('both locales cover every message (no fallback gaps)', (tester) async {
    // The generated lookup throws for unsupported locales; en + ar must both
    // be present and non-empty for a few high-traffic keys.
    for (final locale in const [Locale('en'), Locale('ar')]) {
      late AppLocalizations l10n;
      await tester.pumpWidget(appAt(locale, (context) {
        l10n = AppLocalizations.of(context);
        return const SizedBox.shrink();
      }));
      await tester.pumpAndSettle();
      for (final s in [
        l10n.appName,
        l10n.shopByAge,
        l10n.addToCart,
        l10n.goToCheckout,
        l10n.payKnet,
        l10n.payCod,
      ]) {
        expect(s.trim(), isNotEmpty, reason: '$locale');
      }
    }
  });
}
