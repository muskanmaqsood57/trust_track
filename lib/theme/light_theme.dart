import 'package:flutter_up/themes/up_theme_data.dart';
import 'package:flutter_up/themes/up_themes.dart';
import 'package:trust_track/theme/light_theme_data.dart';

final UpThemeData lightTheme = UpThemes.generateThemeByColor(
  baseColor: baseColor,
  isDark: false,
  primaryColor: primaryColor,
  secondaryColor: lightThemeData["secondaryColor"],
  warnColor: lightThemeData["warnColor"],
  tertiaryColor: lightThemeData["tertiaryColor"],
  successColor: lightThemeData["successColor"],
).updateStyle(
  primaryStyle: primaryStyle,
  warnStyle: warnStyle,
  secondaryStyle: secondaryStyle,
  basicStyle: basicStyle,
  tertiaryStyle: tertiaryStyle,
);
