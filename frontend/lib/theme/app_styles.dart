import 'package:flutter/material.dart';

// app_styles.dart

class AppSpacing {
  static const double screenMargin = 16;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: screenMargin);

  static const EdgeInsets screenPaddingWithTop =
      EdgeInsets.fromLTRB(screenMargin, 16, screenMargin, 0);
}


class AppColors {
  // Core Colors

  static const Color Error = Color(0xFFC50004);
  static const Color Success = Color(0xFF19B03F);
  static const Color Alert = Color(0xFFEDE202);

  static const Color Primary = Color(0xFF1F1F1F);
  static const Color PrimaryLighter = Color(0xFF606060);

  static const Color Secondary = Color(0xFFD1D1D6);
  static const Color Tertiary = Color(0xFFE5E5EA);

  static const Color White = Color(0xFFFFFFFF);

  static const Color Background = Color(0xFFF7F7FA);
  static const Color DarkerBackground = Color(0xFFE1E1E4);

  static const Color Accent = Color(0xFF0568A6);

  static const Color CategoryBlue = Color(0xFF0378A6);
  static const Color CategoryGreen = Color(0xFF008768);
  static const Color CategoryMagenta = Color(0xFFD63A57);
  static const Color CategoryPurple = Color(0xFF7868A1);
  static const Color CategoryOrange = Color(0xFFF28705);

  static const Color AIModuleBlue = Color(0xFF0568A6);
  static const Color AIModuleMagenta = Color(0xFFD93B58);
}

class AppGradients {
  static const LinearGradient AIModuleIndicator = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.AIModuleBlue,
      AppColors.AIModuleMagenta,
    ],
  );
}

class AppTextStyles {
  // LEXEND

  static const TextStyle Header = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 25,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  static const TextStyle Heading1 = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  static const TextStyle Heading2 = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  // OUTFIT

  static const TextStyle Body = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle BodyMedium = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle BodyBold = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle TinyBody = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle TinyBodyMediumLink = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );

  static const TextStyle TinyBodyBold = TextStyle(
    fontFamily: 'Outfit',
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
}

