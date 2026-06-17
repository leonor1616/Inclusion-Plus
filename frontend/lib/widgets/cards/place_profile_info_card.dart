import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_styles.dart';

class PlaceProfileInfoCard extends StatelessWidget {
  final String? status;
  final String? address;
  final String? email;
  final String? phone;

  const PlaceProfileInfoCard({
    super.key,
    this.status,
    this.address,
    this.email,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.Background,
        border: Border.all(color: AppColors.Primary),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          if (status != null)
            _InfoRow(
              iconAsset: 'assets/icons/clock.svg',
              label: 'Status:',
              value: status!,
            ),
          if (address != null)
            _InfoRow(
              iconAsset: 'assets/icons/location.svg',
              label: 'Address:',
              value: address!,
            ),
          if (email != null)
            _InfoRow(
              iconAsset: 'assets/icons/email.svg',
              label: 'Email:',
              value: email!,
            ),
          if (phone != null)
            _InfoRow(
              iconAsset: 'assets/icons/phone.svg',
              label: 'Phone Number:',
              value: phone!,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;

  const _InfoRow({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(
              AppColors.Accent,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.Body.copyWith(
                  color: AppColors.Primary,
                ),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: AppTextStyles.BodyBold.copyWith(
                      color: AppColors.Primary,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}