import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/account/account_screen.dart';

class AppHeader extends StatelessWidget {
  final String logoAsset;
  final bool showAccountButton;
  final VoidCallback? onAccountTap;

  const AppHeader({
    super.key,
    required this.logoAsset,
    this.showAccountButton = true,
    this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        0,
      ),
      child: SizedBox(
        height: 42,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              logoAsset,
              height: 22,
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE5E5E5),
                      border: Border.all(
                        color: const Color(0xFF2B2B2B),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 22,
                      color: Color(0xFF2B2B2B),
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