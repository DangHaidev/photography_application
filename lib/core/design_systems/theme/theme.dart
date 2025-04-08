import "package:flutter/material.dart";

import "app_typography.dart";

class BMaterialTheme {
  BMaterialTheme._();

  static ThemeData light() {
    return _theme(_lightScheme().toColorScheme());
  }

  static ThemeData dark() {
    return _theme(_darkScheme().toColorScheme());
  }

  static ThemeData _theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: appTextTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  static MaterialScheme _lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff895120),
      surfaceTint: Color(0xff895120),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdcc4),
      onPrimaryContainer: Color(0xff2f1400),
      secondary: Color(0xff745944),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdcc4),
      onSecondaryContainer: Color(0xff2a1707),
      tertiary: Color(0xff5d6136),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe3e7af),
      onTertiaryContainer: Color(0xff1a1d00),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      background: Color(0xfffff8f5),
      onBackground: Color(0xff221a14),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff221a14),
      surfaceVariant: Color(0xfff3dfd2),
      onSurfaceVariant: Color(0xff51443b),
      outline: Color(0xff84746a),
      outlineVariant: Color(0xffd6c3b7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382f28),
      inverseOnSurface: Color(0xfffeeee4),
      inversePrimary: Color(0xffffb780),
      primaryFixed: Color(0xffffdcc4),
      onPrimaryFixed: Color(0xff2f1400),
      primaryFixedDim: Color(0xffffb780),
      onPrimaryFixedVariant: Color(0xff6d3a09),
      secondaryFixed: Color(0xffffdcc4),
      onSecondaryFixed: Color(0xff2a1707),
      secondaryFixedDim: Color(0xffe4bfa7),
      onSecondaryFixedVariant: Color(0xff5b412f),
      tertiaryFixed: Color(0xffe3e7af),
      onTertiaryFixed: Color(0xff1a1d00),
      tertiaryFixedDim: Color(0xffc6ca95),
      onTertiaryFixedVariant: Color(0xff464a20),
      surfaceDim: Color(0xffe7d7ce),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1e9),
      surfaceContainer: Color(0xfffbebe1),
      surfaceContainerHigh: Color(0xfff5e5dc),
      surfaceContainerHighest: Color(0xfff0dfd6),
    );
  }

  static MaterialScheme _darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb780),
      surfaceTint: Color(0xffffb780),
      onPrimary: Color(0xff4e2600),
      primaryContainer: Color(0xff6d3a09),
      onPrimaryContainer: Color(0xffffdcc4),
      secondary: Color(0xffe4bfa7),
      onSecondary: Color(0xff422b1a),
      secondaryContainer: Color(0xff5b412f),
      onSecondaryContainer: Color(0xffffdcc4),
      tertiary: Color(0xffc6ca95),
      onTertiary: Color(0xff2f330c),
      tertiaryContainer: Color(0xff464a20),
      onTertiaryContainer: Color(0xffe3e7af),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      background: Color(0xff19120d),
      onBackground: Color(0xfff0dfd6),
      surface: Color(0xff19120d),
      onSurface: Color(0xfff0dfd6),
      surfaceVariant: Color(0xff51443b),
      onSurfaceVariant: Color(0xffd6c3b7),
      outline: Color(0xff9f8d82),
      outlineVariant: Color(0xff51443b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd6),
      inverseOnSurface: Color(0xff382f28),
      inversePrimary: Color(0xff895120),
      primaryFixed: Color(0xffffdcc4),
      onPrimaryFixed: Color(0xff2f1400),
      primaryFixedDim: Color(0xffffb780),
      onPrimaryFixedVariant: Color(0xff6d3a09),
      secondaryFixed: Color(0xffffdcc4),
      onSecondaryFixed: Color(0xff2a1707),
      secondaryFixedDim: Color(0xffe4bfa7),
      onSecondaryFixedVariant: Color(0xff5b412f),
      tertiaryFixed: Color(0xffe3e7af),
      onTertiaryFixed: Color(0xff1a1d00),
      tertiaryFixedDim: Color(0xffc6ca95),
      onTertiaryFixedVariant: Color(0xff464a20),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff413731),
      surfaceContainerLowest: Color(0xff140d08),
      surfaceContainerLow: Color(0xff221a14),
      surfaceContainer: Color(0xff261e18),
      surfaceContainerHigh: Color(0xff312822),
      surfaceContainerHighest: Color(0xff3c332d),
    );
  }
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: background,
      onSurface: onBackground,
      surfaceContainerHigh: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}
