import 'package:flutter/material.dart';
import 'package:flutter_up/themes/up_style.dart';
import 'package:flutter_up/themes/up_themes.dart';

Map<String, dynamic> lightThemeData = {
  "isDark": true,
  "baseColor": Colors.white,
  "primaryColor": const Color.fromARGB(255, 93, 69, 218),
  "secondaryColor": const Color.fromARGB(31, 74, 71, 71),
  "warnColor": Colors.red,
  "tertiaryColor": const Color.fromARGB(31, 131, 125, 125),
  "successColor": Colors.green,
};

MaterialColor helperColor = UpThemes.generateMaterialFromSingleColor(
  const Color.fromARGB(255, 236, 235, 235),
);
Color baseColor = lightThemeData["baseColor"];
Color primaryColor = lightThemeData["primaryColor"];

Color contrastBaseColor = UpThemes.getContrastColor(baseColor);
Color contrastPrimaryColor = UpThemes.getContrastColor(primaryColor);

MaterialColor baseMaterialColor = UpThemes.generateMaterialFromSingleColor(
  baseColor,
);
MaterialColor primaryMaterialColor = UpThemes.generateMaterialFromSingleColor(
  primaryColor,
);
MaterialColor warnMaterialColor = UpThemes.generateMaterialFromSingleColor(
  lightThemeData["warnColor"],
);
MaterialColor secondaryMaterialColor = UpThemes.generateMaterialFromSingleColor(
  lightThemeData["secondaryColor"],
);
MaterialColor tertiaryMaterialColor = UpThemes.generateMaterialFromSingleColor(
  lightThemeData["tertiaryColor"],
);
MaterialColor basicMaterialColor = UpThemes.generateMaterialFromSingleColor(
  baseMaterialColor.shade100,
);

UpStyle primaryStyle =
    UpThemes.generateStyleByMaterial(
      inputColor: primaryMaterialColor,
      contrastColor: UpThemes.generateMaterialFromSingleColor(
        UpThemes.getContrastColor(primaryColor),
      ),
      baseColor: baseMaterialColor,
    ).copyWith(
      UpStyle(
        scaffoldBodyColor: baseColor,
        datePickerOnSurfaceColor: contrastBaseColor,
        datePickerPrimaryColor: primaryColor,
        datePickerSurfaceColor: baseMaterialColor.shade200,
        datePickerOnPrimaryColor: contrastBaseColor,
        timePickerOnSurfaceColor: contrastBaseColor,
        timePickerPrimaryColor: primaryColor,
        timePickerSurfaceColor: baseMaterialColor.shade600,
        timePickerOnPrimaryColor: contrastPrimaryColor,
        tableBorderRadius: 17,
        checkboxLabelColor: contrastBaseColor,
        radioButtonLabelColor: contrastBaseColor,
        radioButtonBorderColor: helperColor,
        checkboxBorderColor: helperColor,
        appBarColor: baseMaterialColor.shade600,

        textfieldFilledColor: const Color.fromARGB(255, 236, 235, 235),
        alertDialogShapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        alertDialogBackgroundColor: const Color.fromARGB(255, 236, 235, 235),
        textfieldBorderRadius: 16,
        textfieldHintColor: contrastBaseColor,
        textfieldLabelColor: contrastBaseColor,
        textfieldTextColor: contrastBaseColor,
        dropdownBorderRadius: 16,

        dropdownFilledColor: const Color.fromARGB(255, 236, 235, 235),
        dropdownMenuColor: const Color.fromARGB(255, 255, 254, 254),
        dropdownLabelColor: contrastBaseColor,
        dropdownTextColor: contrastBaseColor,
        textColor: UpThemes.getContrastColor(baseColor),
        tableHeaderTextWeight: FontWeight.w900,
        tableHeaderTextSize: 14,

        heading5Weight: FontWeight.w900,
        textfieldBorderColor: helperColor,
        dropdownBorderColor: helperColor,

        buttonBorderRadius: 22,
        tableRowColor: const Color.fromARGB(255, 255, 254, 254),
        expansionTileBackgroundColor: Colors.transparent,
        expansionTileCollapsedBackgroundColor: Colors.transparent,
        drawerGradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            baseMaterialColor.shade600,
            const Color.fromARGB(255, 245, 245, 245),
          ],
        ),
        listTileTextColor: contrastBaseColor,
        listTileColor: Colors.transparent,
        listTileSelectedTileColor: primaryColor,
        listTileSelectedIconColor: UpThemes.getContrastColor(primaryColor),
        listTileSelectedTextColor: UpThemes.getContrastColor(primaryColor),
        listTileIconColor: contrastBaseColor,
        expansionTileCollapsedIconColor: contrastBaseColor,
        expansionTileIconColor: contrastBaseColor,

        // tableBorderColor: Color.fromRGBO(222, 218, 218, 1))
        // tableHeaderTextColor: contrastBaseColor,
        // tableHeaderColor: const Color.fromARGB(255, 226, 214, 230),
        tableHeaderTextColor: contrastPrimaryColor,
        tableIconColor: contrastPrimaryColor,
        tableHeaderColor: primaryColor,

        iconColor: contrastBaseColor,
        cardHeaderColor: primaryColor,
        cardHeaderGradient: null,
        cardRadius: 15,
        cardBorder: Border.all(
          width: 1,
          style: BorderStyle.solid,
          color: const Color.fromRGBO(222, 218, 218, 1),
        ),
        cardBodyGradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            baseMaterialColor.shade600,
            const Color.fromARGB(255, 245, 245, 245),
          ],
        ),
      ),
    );
UpStyle warnStyle = UpThemes.generateStyleByMaterial(
  inputColor: warnMaterialColor,
  contrastColor: UpThemes.generateMaterialFromSingleColor(
    UpThemes.getContrastColor(lightThemeData["warnColor"]),
  ),
  baseColor: baseMaterialColor,
).copyWith(UpStyle(buttonBorderRadius: 22));

UpStyle secondaryStyle =
    UpThemes.generateStyleByMaterial(
      inputColor: secondaryMaterialColor,
      contrastColor: UpThemes.generateMaterialFromSingleColor(
        UpThemes.getContrastColor(lightThemeData["secondaryColor"]),
      ),
      baseColor: baseMaterialColor,
    ).copyWith(
      UpStyle(
        buttonBorderRadius: 22,
        tableHeaderTextColor: contrastBaseColor,
        tableIconColor: contrastBaseColor,
        tableRowColor: Colors.transparent,
        tableRowFocusedColor: Colors.transparent,
        tableRowHoverColor: Colors.transparent,
        tableRowPressedColor: Colors.transparent,
        tableHeaderColor: Colors.transparent,
        tableBorderColor: Colors.transparent,
        tableFooterColor: Colors.transparent,
        tableHeadingRowHeight: 18,
        cardHeaderColor: primaryColor,
        cardHeaderGradient: null,
        cardRadius: 15,
        cardBorder: Border.all(
          width: 1,
          style: BorderStyle.solid,
          color: const Color.fromRGBO(222, 218, 218, 1),
        ),
        cardBodyColor: primaryMaterialColor.shade100,
        cardBodyGradient: null,
      ),
    );

UpStyle tertiaryStyle =
    UpThemes.generateStyleByMaterial(
      inputColor: tertiaryMaterialColor,
      contrastColor: UpThemes.generateMaterialFromSingleColor(
        UpThemes.getContrastColor(lightThemeData["tertiaryColor"]),
      ),
      baseColor: baseMaterialColor,
    ).copyWith(
      UpStyle(
        buttonBorderRadius: 22,
        buttonBackgroundColor: Colors.transparent,
        buttonTextColor: contrastBaseColor,
      ),
    );
UpStyle basicStyle = UpThemes.generateStyleByMaterial(
  inputColor: basicMaterialColor,
  contrastColor: UpThemes.generateMaterialFromSingleColor(
    UpThemes.getContrastColor(baseMaterialColor.shade100),
  ),
  baseColor: baseMaterialColor,
).copyWith(UpStyle(buttonBorderRadius: 22));
