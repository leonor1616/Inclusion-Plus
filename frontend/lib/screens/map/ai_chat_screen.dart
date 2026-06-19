import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/map_place_model.dart';
import '../../theme/app_styles.dart';

class AIChatScreen extends StatefulWidget {
  final MapPlace place;

  const AIChatScreen({super.key, required this.place});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  String get _placeholderResponse {
    return 'I can help you understand the accessibility conditions for this place. For now this is a placeholder response until the AI service is connected.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Background,
      appBar: AppBar(
        backgroundColor: AppColors.Background,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        centerTitle: true,
        automaticallyImplyLeading: true,
        leadingWidth: 110,
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.Primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Back',
                style: AppTextStyles.Body.copyWith(
                  color: AppColors.Primary,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          'Ask AI Assistant',
          style: AppTextStyles.Heading2.copyWith(
            color: AppColors.Primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          8,
          AppSpacing.screenMargin,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(1.4),
              decoration: BoxDecoration(
                gradient: AppGradients.AIModuleIndicator,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.White,
                  borderRadius: BorderRadius.circular(10.6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/quick_phrases.svg',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.place.name} Accessibility Summary',
                            style: AppTextStyles.BodyBold.copyWith(
                              color: AppColors.Primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _placeholderResponse,
                      textAlign: TextAlign.justify,
                      style: AppTextStyles.Body.copyWith(
                        color: AppColors.Primary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'AI Assistant is prone to errors. Take information with caution.',
                textAlign: TextAlign.center,
                style: AppTextStyles.TinyBody.copyWith(
                  color: AppColors.PrimaryLighter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}