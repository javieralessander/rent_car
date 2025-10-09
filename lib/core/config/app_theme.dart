import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF3F78C5);
  static const Color secondary = Color(0xFF1AA890);
  static const Color neutralLight = Color(0xFFE2D6D2);
  static const Color neutralDark = Color(0xFF1E1E1E);
  static const Color dark = Color(0xFF222831);

  static const Color blue = Color(0xFF007BFF);
  static const Color indigo = Color(0xFF6610F2);
  static const Color purple = Color(0xFF6F42C1);
  static const Color pink = Color(0xFFE83E8C);
  static const Color red = Color(0xFFDC3545);
  static const Color orange = Color(0xFFFD7E14);
  static const Color yellow = Color(0xFFFFC107);
  static const Color green = Color(0xFF28A745);
  static const Color teal = Color(0xFF20C997);
  static const Color cyan = Color(0xFF17A2B8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF6C757D);
  static const Color grayDark = Color(0xFF343A40);
  static const Color grayLight = Color(0xFFCED4DA);
  static const Color black = Color(0xFF000000);

  static const Color success = Color(0xFF40C057);
  static const Color info = Color(0xFF2F8BE6);
  static const Color warning = Color(0xFFF77E17);
  static const Color danger = Color(0xFFEE2A24);
  static const Color light = Color(0xFFDBDEE5);
  static const Color facebookLinkBlue = Color(0xFF365899);
  static const Color facebookLinkWhite = Color(0xFFFFFFFF);
  static const Color appleLinkBlack = Color(0xFF000000);
  static const Color appleLinkWhite = Color(0xFFFFFFFF);
  static const Color googleLinkRed = Color(0xFF4285F4);

  static const Color devtoPrimary = Color(0xff508CD6);
  static const Color devtoSecondary = Color(0xffCDB7B3);
  static const Color devtoBackgroundColor = Color(0xff282929);
  static const Color devtoCanvasColors = Color(0xff168E7C);

  static const contentColorBlue = Color(0xFF4285F4);
  static const contentColorYellow = Color(0xFFF4B400);
  static const contentColorPurple = Color(0xFFAB47BC);
  static const contentColorGreen = Color(0xFF0F9D58);
  static const contentColorRed = Color(0xFFEA4335); // <-- agrega esta línea
  static const contentColorBlack = Color(0xFF000000);
  static const contentColorOrange = Color(0xFFFD7E14);
  static const contentColorPink = Color(0xFFE83E8C);
  static const Color borderColor = Color(0xFFCCCCCC);
  static const Color mainTextColor1 = Color(0xFF222222);

  static const Color primaryColor = Color(0xFF1976D2);
}

class AppTheme {
  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        iconTheme: IconThemeData(color: AppColors.black),
        titleTextStyle: TextStyle(
          color: AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: AppColors.neutralDark),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.grayDark),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        shadowColor: AppColors.grayLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(AppColors.white),
          foregroundColor: WidgetStatePropertyAll<Color>(
            AppColors.appleLinkBlack,
          ),
          iconColor: WidgetStatePropertyAll<Color>(AppColors.black),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.info),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        errorStyle: TextStyle(color: AppColors.red),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  // Tema oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.dark,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: AppColors.neutralLight),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.gray),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        shadowColor: AppColors.gray,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(AppColors.dark),
          foregroundColor: WidgetStatePropertyAll<Color>(
            AppColors.appleLinkBlack,
          ),
          iconColor: WidgetStatePropertyAll<Color>(AppColors.white),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.info),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        errorStyle: TextStyle(color: AppColors.red),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
