// frontend/lib/widgets/buttons/bottom_sheet_toggle_button.dart

import 'package:flutter/material.dart';

import '../../theme/app_styles.dart';

class BottomSheetToggleButton extends StatelessWidget {
  final bool isExpanded;
  final String collapsedText;
  final String expandedText;
  final VoidCallback onTap;
  final Widget? leading;

  const BottomSheetToggleButton({
    super.key,
    required this.isExpanded,
    required this.collapsedText,
    required this.expandedText,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final text = isExpanded ? expandedText : collapsedText;

    return Semantics(
      button: true,
      label: text,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.Accent.withOpacity(0.12),
          highlightColor: AppColors.Accent.withOpacity(0.08),
          child: leading == null
              ? Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.TinyBody.copyWith(
                      color: AppColors.PrimaryLighter,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(child: leading!),
                    const SizedBox(width: 16),
                    Text(
                      text,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.TinyBody.copyWith(
                        color: AppColors.PrimaryLighter,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
