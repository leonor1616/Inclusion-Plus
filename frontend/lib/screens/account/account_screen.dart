import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../theme/app_styles.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final fullName = user?.fullName?.trim();
    final displayName = fullName != null && fullName.isNotEmpty
        ? fullName
        : 'Francisco Soares';

    return Scaffold(
      backgroundColor: AppColors.Background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            const _AccountStatusBar(),
            const SizedBox(height: 8),
            const _AccountTopBar(),
            const SizedBox(height: 24),
            _ProfileSummaryCard(
              name: displayName,
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, color: AppColors.Secondary),
            const SizedBox(height: 24),
            _AccountMenuCard(
              iconAsset: 'assets/icons/person_filled.svg',
              title: 'Personal Information',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _AccountMenuCard(
              iconAsset: 'assets/icons/book_ribbon.svg',
              title: 'Saved',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _AccountMenuCard(
              iconAsset: 'assets/icons/community.svg',
              title: 'Community Activity',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _AccountMenuCard(
              iconAsset: 'assets/icons/settings.svg',
              title: 'Settings',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _AccountMenuCard(
              materialIcon: Icons.logout,
              title: 'Logout',
              onTap: () {
                context.read<AuthProvider>().logout();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _AccountMenuCard(
              materialIcon: Icons.delete_outline,
              title: 'Delete Account',
              isDanger: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountStatusBar extends StatelessWidget {
  const _AccountStatusBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: Row(
        children: [
          const SizedBox(width: 38),
          Text('9:41', style: AppTextStyles.TinyBodyBold),
          const Spacer(),
          const Icon(Icons.signal_cellular_alt, size: 16, color: AppColors.Primary),
          const SizedBox(width: 6),
          const Icon(Icons.wifi, size: 16, color: AppColors.Primary),
          const SizedBox(width: 6),
          const Icon(Icons.battery_full, size: 18, color: AppColors.Primary),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _AccountTopBar extends StatelessWidget {
  const _AccountTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: SizedBox(
                height: 44,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: AppColors.Primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: AppTextStyles.TinyBody.copyWith(
                        color: AppColors.Primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            'Your Account',
            style: AppTextStyles.Heading2.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.Primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final String name;
  const _ProfileSummaryCard({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.White,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.Primary,
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: AppTextStyles.TinyBody.copyWith(
                color: AppColors.Primary,
                height: 20 / 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.Heading2.copyWith(
                      color: AppColors.Primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Iscte-IUL Student'),
                  const SizedBox(height: 8),
                  const Text('Mobility Difficulties'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          const _ProfilePlaceholder(size: 88),
        ],
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  final double size;

  const _ProfilePlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.Background,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: size - 10,
        height: size - 10,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.White,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.Secondary,
            width: 3,
          ),
        ),
        child: SvgPicture.asset(
          'assets/icons/person_filled.svg',
          width: size * 0.58,
          height: size * 0.58,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            AppColors.Primary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _AccountMenuCard extends StatelessWidget {
  final String title;
  final String? iconAsset;
  final IconData? materialIcon;
  final bool isDanger;
  final VoidCallback onTap;

  const _AccountMenuCard({
    required this.title,
    required this.onTap,
    this.iconAsset,
    this.materialIcon,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.Error : AppColors.Primary;
    final arrowColor = isDanger ? AppColors.Error : AppColors.Accent;

    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 65,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.White,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDanger ? AppColors.Error : AppColors.PrimaryLighter,
              width: 1.4,
            ),
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
              SizedBox(
                width: 24,
                height: 24,
                child: iconAsset != null
                    ? SvgPicture.asset(
                        iconAsset!,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          color,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        materialIcon,
                        size: 24,
                        color: color,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.Body.copyWith(
                    color: color,
                    height: 1,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/arrow_go_blue.svg',
                width: 33,
                height: 33,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  arrowColor,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
