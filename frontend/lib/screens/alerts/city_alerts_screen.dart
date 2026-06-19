import 'package:flutter/material.dart';

import '../../theme/app_styles.dart';

class CityAlertsScreen extends StatelessWidget {
  const CityAlertsScreen({super.key});

  static const List<_CityAlertData> _alerts = [
    _CityAlertData(
      title: 'Metro Yellow Line Closed',
      description: 'Yellow line closed due to weather conditions.',
      imageAsset: 'assets/images/metro.png',
    ),
    _CityAlertData(
      title: 'Weather Alert - Heavy Rain',
      description: 'Heavy rain expected this afternoon.',
      imageAsset: 'assets/images/weather_rain.jpg',
    ),
    _CityAlertData(
      title: 'Metro Yellow Line Closed',
      description: 'Yellow line closed due to weather conditions.',
      imageAsset: 'assets/images/metro.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _AlertsStatusBar(),
            _AlertsTopBar(onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _alerts.length + 1,
                separatorBuilder: (_, index) {
                  if (index >= _alerts.length - 1) {
                    return const SizedBox(height: 8);
                  }

                  return const SizedBox(height: 16);
                },
                itemBuilder: (context, index) {
                  if (index == _alerts.length) {
                    return Center(
                      child: Text(
                        'No Older Alerts',
                        style: AppTextStyles.TinyBody.copyWith(
                          color: AppColors.PrimaryLighter,
                        ),
                      ),
                    );
                  }

                  return _AlertListCard(alert: _alerts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertsStatusBar extends StatelessWidget {
  const _AlertsStatusBar();

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

class _AlertsTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _AlertsTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
              width: 76,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
                child: SizedBox(
                  height: 44,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back, size: 18, color: AppColors.Primary),
                      const SizedBox(width: 8),
                      Text(
                        'Back',
                        style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Alerts in your city area',
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.BodyBold.copyWith(
                      color: AppColors.Primary,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 84,
              height: 28,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.Error,
                borderRadius: BorderRadius.circular(899),
              ),
              child: Text(
                '3 Alerts',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: AppTextStyles.TinyBodyBold.copyWith(
                  color: AppColors.White,
                  height: 20 / 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertListCard extends StatelessWidget {
  final _CityAlertData alert;

  const _AlertListCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 122,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.Tertiary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              alert.imageAsset,
              width: 86,
              height: 86,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.TinyBodyBold.copyWith(
                    color: AppColors.Primary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.TinyBody.copyWith(
                    color: AppColors.Primary,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 4),
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
    );
  }
}

class _CityAlertData {
  final String title;
  final String description;
  final String imageAsset;

  const _CityAlertData({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}
