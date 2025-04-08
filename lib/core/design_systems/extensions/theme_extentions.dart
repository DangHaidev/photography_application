import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

extension ThemeExtentions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  //Typography
  TextStyle get displayLarge => textTheme.displayLarge!;

  TextStyle get displayMedium => textTheme.displayMedium!;

  TextStyle get displaySmall => textTheme.displaySmall!;

  TextStyle get headlineLarge => textTheme.headlineLarge!;

  TextStyle get headlineMedium => textTheme.headlineMedium!;

  TextStyle get headlineSmall => textTheme.headlineSmall!;

  TextStyle get titleLarge => textTheme.titleLarge!;

  TextStyle get titleMedium => textTheme.titleMedium!;

  TextStyle get titleSmall => textTheme.titleSmall!;

  TextStyle get bodyLarge => textTheme.bodyLarge!;

  TextStyle get bodyMedium => textTheme.bodyMedium!;

  TextStyle get bodySmall => textTheme.bodySmall!;

  TextStyle get labelLarge => textTheme.labelLarge!;

  TextStyle get labelMedium => textTheme.labelMedium!;

  TextStyle get labelSmall => textTheme.labelSmall!;

  //Typography custom
  TextStyle get specialCaseLarge => GoogleFonts.museoModerno(fontSize: 310.sp, fontWeight: FontWeight.bold);
  TextStyle get specialCase => GoogleFonts.museoModerno(fontSize: 180.sp, fontWeight: FontWeight.bold);

  TextStyle get heading0 => GoogleFonts.museoModerno(fontSize: 62.sp, fontWeight: FontWeight.bold);

  TextStyle get heading1 => GoogleFonts.museoModerno(fontSize: 48.sp, fontWeight: FontWeight.bold);

  TextStyle get heading2 => GoogleFonts.museoModerno(fontSize: 40.sp, fontWeight: FontWeight.bold);

  TextStyle get heading3 => GoogleFonts.museoModerno(fontSize: 32.sp, fontWeight: FontWeight.bold);

  TextStyle get heading4 => GoogleFonts.museoModerno(fontSize: 24.sp, fontWeight: FontWeight.bold);

  TextStyle get heading5 => GoogleFonts.museoModerno(fontSize: 18.sp, fontWeight: FontWeight.bold);

  TextStyle get body1 => GoogleFonts.museoModerno(fontSize: 18.sp, fontWeight: FontWeight.normal);

  TextStyle get body2 => GoogleFonts.museoModerno(fontSize: 12.sp, fontWeight: FontWeight.normal);

  TextStyle get title2 => GoogleFonts.museoModerno(fontSize: 100.sp, fontWeight: FontWeight.bold);

  //Colors
  Color get primary => colorScheme.primary;

  Color get surfaceTint => colorScheme.surfaceTint;

  Color get onPrimary => colorScheme.onPrimary;

  Color get primaryContainer => colorScheme.primaryContainer;

  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;

  Color get secondary => colorScheme.secondary;

  Color get onSecondary => colorScheme.onSecondary;

  Color get secondaryContainer => colorScheme.secondaryContainer;

  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;

  Color get tertiary => colorScheme.tertiary;

  Color get onTertiary => colorScheme.onTertiary;

  Color get tertiaryContainer => colorScheme.tertiaryContainer;

  Color get onTertiaryContainer => colorScheme.onTertiaryContainer;

  Color get error => colorScheme.error;

  Color get onError => colorScheme.onError;

  Color get errorContainer => colorScheme.errorContainer;

  Color get onErrorContainer => colorScheme.onErrorContainer;

  Color get background => colorScheme.surface;

  Color get onBackground => colorScheme.onSurface;

  Color get surface => colorScheme.surface;

  Color get onSurface => colorScheme.onSurface;

  Color get surfaceVariant => colorScheme.surfaceContainerHighest;

  Color get onSurfaceVariant => colorScheme.onSurfaceVariant;

  Color get outline => colorScheme.outline;

  Color get outlineVariant => colorScheme.outlineVariant;

  Color get shadow => colorScheme.shadow;

  Color get scrim => colorScheme.scrim;

  Color get inverseSurface => colorScheme.inverseSurface;

  Color get inversePrimary => colorScheme.inversePrimary;
}
