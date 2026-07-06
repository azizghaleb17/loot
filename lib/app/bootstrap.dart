import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'url_strategy/url_strategy_noop.dart'
    if (dart.library.js_interop) 'url_strategy/url_strategy_web.dart';

/// Init sequence: URL strategy, Hive (IndexedDB on web), persistence boxes.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  await Hive.initFlutter('loot');
  await Future.wait([
    Hive.openBox('settings'),
    Hive.openBox('cart'),
    Hive.openBox('wishlist'),
    Hive.openBox('orders'),
  ]);
}
