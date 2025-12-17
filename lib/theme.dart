
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFFA7DBD8);
const Color backgroundColor = Color(0xFFF0F8F7);
const Color accentColor = Color(0xFFE89A49);

final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: backgroundColor,
  colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
  textTheme: GoogleFonts.ptSansTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    titleTextStyle: GoogleFonts.ptSans(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.ptSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);
