import 'package:flutter/material.dart';

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
  static const TextStyle Header = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w700,
    color: AppColors.Primary,
  );

  static const TextStyle Heading1 = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: AppColors.Primary,
  );

  static const TextStyle Heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.Primary,
  );

  static const TextStyle Body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.Primary,
  );

  static const TextStyle BodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.Primary,
  );

  static const TextStyle BodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.Primary,
  );

  static const TextStyle TinyBody = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.Primary,
  );

  static const TextStyle TinyBodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.Primary,
  );

  static const TextStyle TinyBodyMediumLink = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
    color: AppColors.Primary,
  );
}

