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
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.Tertiary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              if (iconAsset != null) ...[
                SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset(
                    iconAsset!,
                    key: ValueKey(iconAsset),
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    colorFilter: iconColor != null
                        ? ColorFilter.mode(
                            iconColor!,
                            BlendMode.srcIn,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.TinyBodyBold.copyWith(
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                        size: 22,
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
