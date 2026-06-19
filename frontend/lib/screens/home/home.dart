import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/search_bar.dart';
import '../alerts/city_alerts_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onPlanRoute;
  final VoidCallback? onReportIssue;
  final VoidCallback? onRequestHelp;
  final VoidCallback? onIndoorMap;
  final VoidCallback? onElevatorMap;
  final VoidCallback? onRoomGo;
  final VoidCallback? onSeeUniversity;

  const HomeScreen({
    super.key,
    this.onPlanRoute,
    this.onReportIssue,
    this.onRequestHelp,
    this.onIndoorMap,
    this.onElevatorMap,
    this.onRoomGo,
    this.onSeeUniversity,
  });

  @override
  Widget build(BuildContext context) {
    final topSpacing = MediaQuery.of(context).padding.top + 8;

    void openCityAlerts() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CityAlertsScreen()),
      );
    }

    return ColoredBox(
      color: AppColors.Background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          topSpacing,
          AppSpacing.screenMargin,
          24,
        ),
        children: [
          const AppHeader(
            logoAsset: 'assets/logos/inclusion_logo_magenta.svg',
          ),
          const SizedBox(height: 16),
          AppSearchBar(readOnly: true, onTap: onPlanRoute),
          const SizedBox(height: 16),
          Text(
            'Quick Actions',
            style: AppTextStyles.Heading1.copyWith(
              color: AppColors.Primary,
            ),
          ),
          const SizedBox(height: 16),
          _QuickActionsRow(
            onPlanRoute: onPlanRoute,
            onReportIssue: onReportIssue,
            onRequestHelp: onRequestHelp,
            onIndoorMap: onIndoorMap,
          ),
          const SizedBox(height: 32),
          Text(
            'Alerts in your city area (3 Alerts)',
            style: AppTextStyles.Heading1.copyWith(
              color: AppColors.Primary,
            ),
          ),
          const SizedBox(height: 16),
          _CityAlertCard(onTap: openCityAlerts),
          const SizedBox(height: 16),
          _WhiteActionCard(
            leadingAsset: 'assets/icons/warning.svg',
            title: 'See all 3 ongoing issues',
            onTap: openCityAlerts,
          ),
          const SizedBox(height: 32),
          Text(
            'From your University (2 Alerts)',
            style: AppTextStyles.Heading1.copyWith(
              color: AppColors.Primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Elevator Issues (1)',
            style: AppTextStyles.BodyBold,
          ),
          const SizedBox(height: 10),
          _ElevatorIssueCard(onSeeOnMap: onElevatorMap ?? onPlanRoute),
          const SizedBox(height: 32),
          Text(
            'Schedule Changes (1)',
            style: AppTextStyles.BodyBold,
          ),
          const SizedBox(height: 18),
          Text(
            'Applied Mathematics I (AMI23) - Room Update',
            style: AppTextStyles.Body.copyWith(
              color: AppColors.Primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _RoomUpdateCard(onGo: onRoomGo),
          const SizedBox(height: 12),
          _WhiteActionCard(
            leadingAsset: 'assets/icons/school.svg',
            title: 'See more from Iscte-IUL',
            onTap: onSeeUniversity,
          ),
          const SizedBox(height: 48),
          _PlainEditButton(
            title: 'Edit the Home Page',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback? onPlanRoute;
  final VoidCallback? onReportIssue;
  final VoidCallback? onRequestHelp;
  final VoidCallback? onIndoorMap;

  const _QuickActionsRow({
    required this.onPlanRoute,
    required this.onReportIssue,
    required this.onRequestHelp,
    required this.onIndoorMap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QuickAction(
            label: 'Plan\nRoute',
            iconAsset: 'assets/icons/navigate_white.svg',
            color: AppColors.Accent,
            onTap: onPlanRoute,
          ),
          _QuickAction(
            label: 'Report\nIssue',
            iconAsset: 'assets/icons/not_accessible_forward_white.svg',
            color: AppColors.CategoryMagenta,
            onTap: onReportIssue,
          ),
          _QuickAction(
            label: 'Request\nHelp',
            iconAsset: 'assets/icons/support_agent_white.svg',
            color: AppColors.CategoryPurple,
            onTap: onRequestHelp,
          ),
          _QuickAction(
            label: 'Iscte-IUL\nIndoor\nMap',
            iconAsset: 'assets/icons/map_search.svg',
            color: AppColors.CategoryGreen,
            onTap: onIndoorMap,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final String iconAsset;
  final Color color;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.label,
    required this.iconAsset,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label.replaceAll('\n', ' '),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 76,
          height: 122,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  iconAsset,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    AppColors.White,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.TinyBody.copyWith(
                    color: AppColors.Primary,
                    height: 1.16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityAlertCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _CityAlertCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: 'Metro Yellow Line Closed. More Information.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.Tertiary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/metro.png',
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metro Yellow Line Closed',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.TinyBodyBold.copyWith(height: 1.15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Yellow line closed due to weather conditions.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.TinyBody.copyWith(
                        height: 1.18,
                        color: AppColors.Primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'More Information',
                      style: AppTextStyles.TinyBodyMediumLink.copyWith(
                        color: AppColors.Accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteActionCard extends StatelessWidget {
  final String leadingAsset;
  final String title;
  final VoidCallback? onTap;

  const _WhiteActionCard({
    required this.leadingAsset,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      onTap: onTap,
      height: 65,
      borderColor: AppColors.PrimaryLighter,
      borderWidth: 1.4,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SvgPicture.asset(
            leadingAsset,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.Body.copyWith(color: AppColors.Primary),
            ),
          ),
          SvgPicture.asset(
            'assets/icons/arrow_go_blue.svg',
            width: 33,
            height: 33,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _ElevatorIssueCard extends StatelessWidget {
  final VoidCallback? onSeeOnMap;

  const _ElevatorIssueCard({this.onSeeOnMap});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      height: 168,
      borderColor: AppColors.Accent,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Elevator 1', style: AppTextStyles.Body),
              const SizedBox(width: 8),
              Text('•', style: AppTextStyles.Body.copyWith(color: AppColors.Primary)),
              const SizedBox(width: 8),
              Text('Out of Service', style: AppTextStyles.BodyBold),
              const SizedBox(width: 8),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.Error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 13, color: AppColors.White),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Floor 1, Building 1, Iscte-IUL Lisbon Campus',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.Body.copyWith(height: 1.2),
          ),
          const Spacer(),
          AppButton(
            text: 'See on Map',
            fullWidth: true,
            iconAsset: 'assets/icons/navigate_white.svg',
            onPressed: onSeeOnMap,
          ),
        ],
      ),
    );
  }
}

class _RoomUpdateCard extends StatelessWidget {
  final VoidCallback? onGo;

  const _RoomUpdateCard({this.onGo});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/room_1e08.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Room 1E08\n',
                    style: AppTextStyles.BodyBold.copyWith(height: 1.2),
                  ),
                  TextSpan(
                    text: 'Floor 1, Building 1, Iscte-IUL Lisbon Campus',
                    style: AppTextStyles.TinyBody.copyWith(
                      color: AppColors.Primary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          _GoButton(onTap: onGo),
        ],
      ),
    );
  }
}

class _GoButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _GoButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Go',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 98,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.Accent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Go',
                  style: AppTextStyles.Body.copyWith(
                    color: AppColors.White,
                    fontSize: 16,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/navigate_white.svg',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlainEditButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _PlainEditButton({
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.White,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.PrimaryLighter, width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.Body.copyWith(
              color: AppColors.Primary,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? height;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;

  const _CardShell({
    required this.child,
    this.onTap,
    this.height,
    this.borderColor = AppColors.Secondary,
    this.borderWidth = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: height,
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.White,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
