import 'package:flutter_up/locator.dart';

void setupLocator() {
  setupFlutterUpLocators([
    FlutterUpLocators.upDialogService,
    FlutterUpLocators.upNavigationService,
    FlutterUpLocators.upScaffoldService,
    FlutterUpLocators.upSearchService,
    FlutterUpLocators.upUrlService,
    FlutterUpLocators.upLayoutService,
  ]);
}
