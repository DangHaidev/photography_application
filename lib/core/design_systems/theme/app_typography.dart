import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme appTextTheme = TextTheme(
  displayLarge: const TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w800, // ExtraBold
      fontSize: 57),
  displayMedium: const TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w800, // ExtraBold
      fontSize: 45),
  displaySmall: const TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w700, // Bold
      fontSize: 36),
  headlineLarge: GoogleFonts.museoModerno(),
  headlineMedium: const TextStyle(
      fontFamily: 'MuseoModerno',
      fontWeight: FontWeight.bold, // SemiBold
      fontSize: 28),
  headlineSmall: const TextStyle(
      fontFamily: 'MuseoModerno',
      fontWeight: FontWeight.bold, // Regular
      fontSize: 24),
  titleLarge: const TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w700, // Bold
      fontSize: 22),
  titleMedium: const TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w600, // SemiBold
      fontSize: 20),
  titleSmall: const TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w400, // Regular
      fontSize: 18),
  bodyLarge: const TextStyle(
      fontFamily: 'MuseoModerno',
      fontWeight: FontWeight.normal, // Regular
      fontSize: 16),
  bodyMedium: const TextStyle(
      fontFamily: 'MuseoModerno',
      fontWeight: FontWeight.normal, // Light
      fontSize: 14),
  bodySmall: const TextStyle(
      fontFamily: 'MuseoModerno',
      fontWeight: FontWeight.normal, // Light
      fontSize: 12),
  labelLarge: const TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w600, // SemiBold
      fontSize: 14),
  labelMedium: const TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w400, // Regular
      fontSize: 12),
  labelSmall: const TextStyle(
      fontFamily: 'OpenSans',
      fontWeight: FontWeight.w300, // Light
      fontSize: 10),
);
