import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/account/account_screen.dart';
import '../theme/app_styles.dart';

class AppHeader extends StatelessWidget {
  final String logoAsset;
  final bool showAccountButton;
  final VoidCallback? onAccountTap;
  final String? avatarAsset;
  final double horizontalPadding;

  const AppHeader({
    super.key,
    required this.logoAsset,
    this.showAccountButton = true,
    this.onAccountTap,
    this.avatarAsset,
    this.horizontalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              logoAsset,
              height: 30,
              fit: BoxFit.contain,
              semanticsLabel: 'Inclusion+ Logo',
            ),
            if (showAccountButton)
              Semantics(
                button: true,
                label: 'Open account',
                child: GestureDetector(
                  onTap: onAccountTap ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AccountScreen(),
                          ),
                        );
                      },
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.Background,
                      border: Border.all(
                        color: AppColors.Primary,
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarAsset == null
                        ? SvgPicture.asset(
                            'assets/icons/person_filled.svg',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              AppColors.Primary,
                              BlendMode.srcIn,
                            ),
                          )
                        : Image.asset(
                            avatarAsset!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
