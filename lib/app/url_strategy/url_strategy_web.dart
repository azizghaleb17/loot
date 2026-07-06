import 'package:flutter_web_plugins/url_strategy.dart';

/// Web: real paths (`/p/wooden-train-set`), not `/#/p/...` (spec §1.3).
void configureUrlStrategy() => usePathUrlStrategy();
