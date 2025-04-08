import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppGradientTokens {
  const AppGradientTokens._();

  static const gradientMain = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.from(red: 0, green: 0.92, blue: 0.52, alpha: 1),
      Color.from(red: 0.8, green: 0.96, blue: 0.01, alpha: 1),
    ],
  );
  static const gradientSecondary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.from(red: 0.98, green: 0.55, blue: 0.09, alpha: 1),
      Color.from(red: 0.96, green: 0.14, blue: 0.01, alpha: 1),
    ],
  );
  static const gradientTertiary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.from(red: 0.01, green: 0.96, blue: 0.5, alpha: 1),
      Color.from(red: 0.06, green: 0.49, blue: 0.5, alpha: 1),
    ],
  );

  static const gradientLinear = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.from(red: 0, green: 0.14, blue: 0.07, alpha: 1),
      Color.from(red: 0, green: 0.22, blue: 0.23, alpha: 1),
    ],
  );

  //
  // UIColor(red: 0, green: 0.14, blue: 0.07, alpha: 1)
  // UIColor(red: 0, green: 0.22, blue: 0.23, alpha: 1)
  static const gradientRedWOpacity = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.95, green: 0.2, blue: 0.2, alpha: 1),
      Color.from(red: 0.95, green: 0.2, blue: 0.2, alpha: 0.5),
    ],
  );

  static const gradientRedWOpacityActive = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.95, green: 0.2, blue: 0.2, alpha: 1),
      Color.from(red: 0.95, green: 0.2, blue: 0.2, alpha: 0.8),
    ],
  );
  static const gradientBlueWOpacity = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.2, green: 0.36, blue: 0.2, alpha: 0.5),
      Color.from(red: 0.2, green: 0.36, blue: 0.95, alpha: 1),
    ],
  );
  static const gradientBlueWOpacityActive = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.2, green: 0.36, blue: 0.95, alpha: 0.8),
      Color.from(red: 0.2, green: 0.36, blue: 0.95, alpha: 1),
    ],
  );
  static const gradientPurpleWOpacity = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.62, green: 0.2, blue: 0.95, alpha: 1),
      Color.from(red: 0.62, green: 0.2, blue: 0.95, alpha: 0.5),
    ],
  );
  static const gradientPurpleWOpacityActive = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.62, green: 0.2, blue: 0.95, alpha: 1),
      Color.from(red: 0.62, green: 0.2, blue: 0.95, alpha: 0.8),
    ],
  );

  static const gradientCyanWOpacity = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.2, green: 0.72, blue: 0.95, alpha: 0.5),
      Color.from(red: 0.2, green: 0.72, blue: 0.95, alpha: 1),
    ],
  );
  static const gradientCyanWOpacityActive = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.2, green: 0.72, blue: 0.95, alpha: 0.8),
      Color.from(red: 0.2, green: 0.72, blue: 0.95, alpha: 1),
    ],
  );

  static const gradientSolidDefault = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.from(red: 0.2, green: 0.72, blue: 0.95, alpha: 0.8),
    ],
  );
  static const gradientSolidDisabled = LinearGradient(
    colors: [
      AppColors.orangeOrange900,
    ],
  );

  //LinearGradient(
  //               begin: Alignment(0.00, -1.00),
  //               end: Alignment(0, 1),
  //               colors: [Color(0xFF006E3E), Color(0xFF546500)],
  //             )
  static const gradientDropdownDefault = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.from(red: 0, green: 0.92, blue: 0.52, alpha: 1),
      Color.from(red: 0.8, green: 0.96, blue: 0.01, alpha: 1),
    ],
  );
  static const gradientDropdownDisabled = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.from(red: 0, green: 0.43, blue: 0.25, alpha: 1),
      Color.from(red: 0.33, green: 0.4, blue: 0, alpha: 1),
    ],
  );

  //frame player
  static const gradientPlayerDefault = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.95, green: 0.2, blue: 0.2, alpha: 1),
      Color.from(red: 0.95, green: 0.2, blue: 0.2, alpha: 0.8),
    ],
  );

  static const gradientPlayer1 = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.95, green: 0.2, blue: 0.2, alpha: 1),
      Color.from(red: 0.95, green: 0.2, blue: 0.2, alpha: 0.6),
    ],
  );
  static const gradientPlayer2 = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.from(red: 0.2, green: 0.36, blue: 0.95, alpha: 0.6),
      Color.from(red: 0.2, green: 0.36, blue: 0.95, alpha: 1),
    ],
  );

  static LinearGradient settingGradient = LinearGradient(
    begin: Alignment.centerLeft,
    colors: [
      const Color(0xFF16E755).withOpacity(0.2),
      const Color(0xFF18D751).withOpacity(0.1),
      const Color(0xFF16E755).withOpacity(0.2),
    ],
  );

  static const proCaromGradient = LinearGradient(
    begin: Alignment(0.00, -1.00),
    end: Alignment(0, 1),
    colors: [Color(0xFF9F32F2), Color(0x7F5B1C8C)],
  );

  static const fastCaromGradient = LinearGradient(
    begin: Alignment(0.00, -1.00),
    end: Alignment(0, 1),
    colors: [Color(0xFF325CF2), Color(0x4C325CF2)],
  );

  static final proPoolGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.orangeOrange500, AppColors.orangeOrange500.withOpacity(0.2)],
  );

  static const fastPoolGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF09953A), Color(0x330FD330)],
  );

  static const pickleballGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x0009963A), Color(0xFF09963A)],
  );

  static const badmintonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x33EF7F10)],
  );

  static const pickleballGradientText = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.greenGreen300, AppColors.yellowYellow800],
  );

  static const badmintonGradientText = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.orangeOrange500, AppColors.redRed500],
  );

  static const HistoryMatchPlayer1NameGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xCC15E654), Color(0x4C17D751)],
  );

  static const HistoryMatchPlayer2NameGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [Color(0xCC15E654), Color(0x4C17D751)],
  );

  static const HistoryMatchPlayer1Gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF23232), Color(0x7FF23232)],
  );

  static const HistoryMatchPlayer2Gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0x7F325CF2), Color(0xFF325CF2)],
  );

  static const gradientGreenGreen950 = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.greenGreen950,
      AppColors.greenGreen950,
    ],
  );
}
