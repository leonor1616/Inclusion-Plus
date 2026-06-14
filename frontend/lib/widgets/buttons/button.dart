import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';

enum AppButtonVariant {
  accent,
  success,
  error,
  alert,
  disabled,
  outline,
  dark,
}

class AppButton extends StatelessWidget {
  static const double _height = 50;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 8,
  );

  final String text;
  final VoidCallback? onPressed;
  final String? iconAsset;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool fullWidth;
  final bool isLoading;
  final bool iconBeforeText;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.iconAsset,
    this.icon,
    this.variant = AppButtonVariant.accent,
    this.fullWidth = false,
    this.isLoading = false,
    this.iconBeforeText = false,
  });

  Color get _backgroundColor {
    switch (variant) {
      case AppButtonVariant.accent:
        return AppColors.Accent;
      case AppButtonVariant.success:
        return AppColors.Success;
      case AppButtonVariant.error:
        return AppColors.Error;
      case AppButtonVariant.alert:
        return AppColors.Alert;
      case AppButtonVariant.disabled:
        return AppColors.Secondary;
      case AppButtonVariant.outline:
        return AppColors.White;
      case AppButtonVariant.dark:
        return AppColors.Primary;
    }
  }

  Color get _contentColor {
    switch (variant) {
      case AppButtonVariant.alert:
      case AppButtonVariant.disabled:
      case AppButtonVariant.dark:
        return AppColors.White;
      case AppButtonVariant.outline:
        return AppColors.Accent;
      case AppButtonVariant.dark:
        return AppColors.Primary;
      default:
        return AppColors.White;
    }
  }

  Border? get _border {
    if (variant == AppButtonVariant.outline) {
      return Border.all(
        color: AppColors.Primary,
        width: 1,
      );
    }

    return null;
  }

  Color get _splashColor {
    if (variant == AppButtonVariant.outline ||
        variant == AppButtonVariant.disabled ||
        variant == AppButtonVariant.alert ||
        variant == AppButtonVariant.dark) {
      return AppColors.Accent.withOpacity(0.12);
    }

    return AppColors.White.withOpacity(0.20);
  }

  Color get _highlightColor {
    if (variant == AppButtonVariant.outline ||
        variant == AppButtonVariant.disabled ||
        variant == AppButtonVariant.alert ||
        variant == AppButtonVariant.dark) {
      return AppColors.Accent.withOpacity(0.08);
    }

    return AppColors.White.withOpacity(0.12);
  }

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _contentColor,
            ),
          )
        else ...[
          if (iconBeforeText)
            _ButtonIcon(
              iconAsset: iconAsset,
              icon: icon,
              color: _contentColor,
            ),
          if (iconBeforeText && (iconAsset != null || icon != null))
            const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.Body.copyWith(
                color: _contentColor,
              ),
            ),
          ),
          if (!iconBeforeText && (iconAsset != null || icon != null))
            const SizedBox(width: 6),
          if (!iconBeforeText)
            _ButtonIcon(
              iconAsset: iconAsset,
              icon: icon,
              color: _contentColor,
            ),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: !_isDisabled,
      label: text,
      child: Opacity(
        opacity: _isDisabled ? 0.55 : 1,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _isDisabled ? null : onPressed,
              borderRadius: BorderRadius.circular(12),
              splashColor: _splashColor,
              highlightColor: _highlightColor,
              child: Container(
                width: fullWidth ? double.infinity : null,
                height: _height,
                padding: _padding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: _border,
                ),
                child: buttonContent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonIcon extends StatelessWidget {
  final String? iconAsset;
  final IconData? icon;
  final Color color;

  const _ButtonIcon({
    required this.iconAsset,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (iconAsset != null) {
      return SvgPicture.asset(
        iconAsset!,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          color,
          BlendMode.srcIn,
        ),
      );
    }

    if (icon != null) {
      return Icon(
        icon,
        size: 24,
        color: color,
      );
    }

    return const SizedBox.shrink();
  }
}