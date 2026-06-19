import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';

class CheckboxInputBox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? iconAsset;
  final Color? iconColor;

  const CheckboxInputBox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.iconAsset,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: value,
      label: label,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.Tertiary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (iconAsset != null) ...[
                    SvgPicture.asset(
                      iconAsset!,
                      width: 30,
                      height: 30,
                      colorFilter: iconColor != null
                          ? ColorFilter.mode(
                              iconColor!,
                              BlendMode.srcIn,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.BodyMedium,
                  ),
                ],
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.Background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.Primary,
                    width: 1,
                  ),
                ),
                child: value
                    ? const Icon(
                        Icons.check,
                        size: 24,
                        color: AppColors.Accent,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//uso sem ícone

/* CheckboxInputBox(
  label: 'System Settings',
  value: systemSettingsSelected,
  onChanged: (newValue) {
    setState(() {
      systemSettingsSelected = newValue;
    });
  },
), */

//uso com ícone

/*CheckboxInputBox(
  label: 'Light Mode',
  iconAsset: 'assets/icons/light_mode.svg',
  iconColor: AppColors.Accent,
  value: lightModeSelected,
  onChanged: (newValue) {
    setState(() {
      lightModeSelected = newValue;
    });
  },
),*/