import 'package:flutter/material.dart';

class AppColors {
  // Monochrome Royal Velvet color palette
  //static const Color deepVelvet = Color(0xFF2A0712);    // App background / darkest elements
  //static const Color royalVelvet = Color(0xFF4C0D1F);   // Primary background/surface color
  //static const Color velvetHighlight = Color(0xFF6E1431); // Primary accent (buttons, highlights)
  //static const Color velvetLight = Color(0xFF8F1A43);   // Secondary accent (icons, dividers)
  //static const Color velvetPale = Color(0xFFB12254);    // Active states, emphasis
  //static const Color velvetMist = Color(0xFFD32A66);    // Special highlights, badges
  //static const Color shadowBlack = Color(0xFF0A0A0A);   // Panel contrast and shadows
  static const Color deepVelvet = Color(0xFF0A0A0A);    // App background / darkest elements
  static const Color royalVelvet = Color(0xFF1A1A1A);   // Primary background/surface color
  static const Color velvetHighlight = Color(0xFF303030); // Primary accent (buttons, highlights)
  static const Color velvetLight = Color(0xFF555555);   // Secondary accent (icons, dividers)
  static const Color velvetPale = Color(0xFF888888);    // Active states, emphasis
  static const Color velvetMist = Color(0xFFCCCCCC);    // Special highlights, badges
  static const Color shadowBlack = Color(0xFF000000);   // Panel contrast and shadows

  // Material theme colors
  static final ThemeData darkTheme = ThemeData(
    primaryColor: velvetPale,
    scaffoldBackgroundColor: deepVelvet,
    cardColor: royalVelvet,
    appBarTheme: AppBarTheme(
      backgroundColor: deepVelvet,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: velvetMist),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Quicksand',
        color: velvetPale,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white.withOpacity(0.8),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: velvetPale,
      secondary: velvetMist,
      surface: royalVelvet,
      background: deepVelvet,
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: velvetPale,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: velvetMist,
        textStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: velvetPale,
        side: BorderSide(color: velvetPale),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: deepVelvet,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: velvetLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: velvetLight.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: velvetPale),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Quicksand',
        color: velvetLight,
      ),
      hintStyle: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white.withOpacity(0.3),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: deepVelvet,
      selectedItemColor: velvetMist,
      unselectedItemColor: Colors.white.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: velvetHighlight.withOpacity(0.3),
      labelStyle: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
      ),
      selectedColor: velvetPale,
      secondarySelectedColor: velvetMist,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: velvetLight.withOpacity(0.2),
      thickness: 1,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return velvetPale;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: BorderSide(color: velvetLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return velvetPale;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return velvetPale.withOpacity(0.5);
        }
        return Colors.white.withOpacity(0.3);
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return velvetPale;
        }
        return velvetLight;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: velvetPale,
      inactiveTrackColor: velvetLight.withOpacity(0.3),
      thumbColor: velvetMist,
      overlayColor: velvetPale.withOpacity(0.2),
      valueIndicatorColor: velvetPale,
      valueIndicatorTextStyle: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: royalVelvet,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: royalVelvet,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.white.withOpacity(0.8),
        fontSize: 14,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: royalVelvet,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: velvetMist,
      unselectedLabelColor: Colors.white.withOpacity(0.6),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: velvetMist, width: 2),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: velvetPale,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: velvetMist,
      circularTrackColor: velvetLight.withOpacity(0.2),
      linearTrackColor: velvetLight.withOpacity(0.2),
    ),
  );
}
