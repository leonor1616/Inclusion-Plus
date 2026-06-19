import 'package:flutter/material.dart';

import '../theme/app_styles.dart';

class PhoneViewport extends StatelessWidget {
  static const double phoneWidth = 393;
  static const double phoneHeight = 852;

  final Widget child;

  const PhoneViewport({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 600) {
          return child;
        }

        return ColoredBox(
          color: const Color(0xFF3F3F3F),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: phoneWidth,
                  height: phoneHeight,
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: const Size(phoneWidth, phoneHeight),
                    ),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: AppColors.Background),
                      child: ClipRect(child: child),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
