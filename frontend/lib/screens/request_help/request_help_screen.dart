import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_styles.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/navbars/nav_items.dart';
import '../../widgets/navbars/navbar.dart';

enum _RequestHelpStep { options, form, submitted }

class RequestHelpScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onOpenEmergencyMap;

  const RequestHelpScreen({
    super.key,
    this.onNavigateTab,
    this.onOpenEmergencyMap,
  });

  @override
  State<RequestHelpScreen> createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  static const int _locationId = 1;

  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(
    text: 'ISCTE-IUL, Building 1, Floor 2, Room 1...',
  );

  _RequestHelpStep _step = _RequestHelpStep.options;
  DateTime? _submittedAt;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _navigateTab(int index) {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(index);
      return;
    }

    if (index == 0) {
      Navigator.pop(context);
    }
  }

  Future<void> _submitTextRequest() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final token = context.read<AuthProvider>().token;
    if (token != null && token.isNotEmpty) {
      try {
        await ApiService.createHelpRequest(
          token: token,
          incampusUniversityLocationId: _locationId,
          requestType: 'text_support',
          message: _detailsController.text.trim(),
          urgencyLevel: 'now',
        );
      } catch (_) {
        // Keep the prototype flow usable even if the backend is not running.
      }
    }

    if (!mounted) return;
    setState(() {
      _submittedAt = DateTime.now();
      _isSubmitting = false;
      _step = _RequestHelpStep.submitted;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_step) {
      case _RequestHelpStep.options:
        body = _RequestHelpOptions(
          onBack: () => Navigator.pop(context),
          onRequestText: () => setState(() => _step = _RequestHelpStep.form),
          onOpenMap: widget.onOpenEmergencyMap ?? () => _navigateTab(1),
        );
        break;
      case _RequestHelpStep.form:
        body = _RequestHelpForm(
          detailsController: _detailsController,
          locationController: _locationController,
          isSubmitting: _isSubmitting,
          onBack: () => setState(() => _step = _RequestHelpStep.options),
          onSubmit: _submitTextRequest,
        );
        break;
      case _RequestHelpStep.submitted:
        body = _RequestHelpSubmitted(
          details: _detailsController.text.trim(),
          location: _locationController.text.trim().isEmpty
              ? 'ISCTE-IUL, Building 1, Floor 2, Room 1...'
              : _locationController.text.trim(),
          submittedAt: _submittedAt ?? DateTime.now(),
          onBack: () => setState(() => _step = _RequestHelpStep.form),
          onCallSupport: () {},
          onCancelRequest: () => setState(() => _step = _RequestHelpStep.options),
        );
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.Background,
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: AppNavigationBar(
        currentIndex: 0,
        items: AppNavItems.items,
        onTap: _navigateTab,
      ),
    );
  }
}

class _RequestHelpOptions extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRequestText;
  final VoidCallback onOpenMap;

  const _RequestHelpOptions({
    required this.onBack,
    required this.onRequestText,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _RequestStatusBar(),
        _RequestTopBar(title: 'Request Help', onBack: onBack),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assistance from Iscte-IUL Staff', style: AppTextStyles.BodyBold),
              const SizedBox(height: 8),
              Text(
                'Need help on campus? Choose how to get support:',
                style: AppTextStyles.TinyBody.copyWith(
                  color: AppColors.Primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _RequestActionCard(
                title: 'Call Campus Support',
                iconAsset: 'assets/icons/request_phone.svg',
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _RequestActionCard(
                title: 'Request Help via Text',
                iconAsset: 'assets/icons/request_text.svg',
                onTap: onRequestText,
              ),
              const SizedBox(height: 32),
              Text('Emergency Assistance - Contact Information', style: AppTextStyles.BodyBold),
              const SizedBox(height: 24),
              Text(
                'National Emergency Helplines',
                style: AppTextStyles.TinyBodyBold.copyWith(
                  color: AppColors.Error,
                  height: 1,
                ),
              ),
              const SizedBox(height: 24),
              const _EmergencyLine(
                label: 'Emergency Number',
                number: '112',
                description: 'Police · Fire · Medical Emergency',
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: AppColors.PrimaryLighter),
              const SizedBox(height: 16),
              const _EmergencyLine(
                label: 'Health Line (SNS 24)',
                number: '808 24 24 24',
                description: 'Non-emergency health advice',
              ),
              const SizedBox(height: 32),
              Text('Locate Emergency Services', style: AppTextStyles.BodyBold),
              const SizedBox(height: 16),
              _RequestActionCard(
                title: 'See Emergency Services on Map',
                iconAsset: 'assets/icons/map.svg',
                onTap: onOpenMap,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestHelpForm extends StatelessWidget {
  final TextEditingController detailsController;
  final TextEditingController locationController;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const _RequestHelpForm({
    required this.detailsController,
    required this.locationController,
    required this.isSubmitting,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _RequestStatusBar(),
        _RequestTopBar(title: 'Request Help via Text', onBack: onBack),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RequestLabeledField(
                label: 'Requesting assistance to',
                child: _EditableLocationField(controller: locationController),
              ),
              const SizedBox(height: 24),
              Text(
                'Inform us of when you’ll need the assistance\n(optional)',
                style: AppTextStyles.TinyBodyBold.copyWith(
                  color: AppColors.Primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Assistance needed at: ', style: AppTextStyles.TinyBody),
                    TextSpan(text: 'Right Now', style: AppTextStyles.TinyBodyBold),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _OutlineButtonCard(
                title: 'Schedule assistance',
                iconAsset: 'assets/icons/request_clock.svg',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _RequestLabeledField(
                label: 'Provide details (optional)',
                child: _DetailsTextArea(controller: detailsController),
              ),
              const SizedBox(height: 32),
              Center(
                child: AppButton(
                  text: 'Request Assistance',
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : onSubmit,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestHelpSubmitted extends StatelessWidget {
  final String details;
  final String location;
  final DateTime submittedAt;
  final VoidCallback onBack;
  final VoidCallback onCallSupport;
  final VoidCallback onCancelRequest;

  const _RequestHelpSubmitted({
    required this.details,
    required this.location,
    required this.submittedAt,
    required this.onBack,
    required this.onCallSupport,
    required this.onCancelRequest,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const _RequestStatusBar(),
        _RequestTopBar(title: 'Assistance in Progress', onBack: onBack),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Request submitted successfully',
                    style: AppTextStyles.BodyMedium.copyWith(color: AppColors.Primary),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset('assets/icons/green_check.svg', width: 24, height: 24),
                ],
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Status: ', style: AppTextStyles.TinyBodyBold),
                    TextSpan(text: 'Assistance will arrive in 7 min', style: AppTextStyles.TinyBody),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Request Overview', style: AppTextStyles.BodyMedium.copyWith(color: AppColors.Primary)),
              const SizedBox(height: 16),
              _RequestOverviewCard(
                location: location,
                details: details,
                submittedAt: submittedAt,
              ),
              const SizedBox(height: 32),
              Text('Additional Support', style: AppTextStyles.BodyMedium.copyWith(color: AppColors.Primary)),
              const SizedBox(height: 16),
              _RequestActionCard(
                title: 'Call Campus Support',
                iconAsset: 'assets/icons/request_phone.svg',
                onTap: onCallSupport,
              ),
              const SizedBox(height: 16),
              _CancelRequestCard(onTap: onCancelRequest),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestStatusBar extends StatelessWidget {
  const _RequestStatusBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: Row(
        children: [
          const SizedBox(width: 54),
          Text('9:41', style: AppTextStyles.TinyBodyBold),
          const Spacer(),
          const Icon(Icons.signal_cellular_alt, size: 16, color: AppColors.Primary),
          const SizedBox(width: 6),
          const Icon(Icons.wifi, size: 16, color: AppColors.Primary),
          const SizedBox(width: 6),
          const Icon(Icons.battery_full, size: 18, color: AppColors.Primary),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _RequestTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _RequestTopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
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
                      Text('Back', style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 86),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
              textAlign: TextAlign.center,
              style: AppTextStyles.Heading2.copyWith(
                color: AppColors.Primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestActionCard extends StatelessWidget {
  final String title;
  final String iconAsset;
  final VoidCallback onTap;

  const _RequestActionCard({required this.title, required this.iconAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _RequestCardShell(
      onTap: onTap,
      height: 65,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SvgPicture.asset(iconAsset, width: 32, height: 32, fit: BoxFit.contain),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary, height: 1),
            ),
          ),
          SvgPicture.asset('assets/icons/arrow_go_blue.svg', width: 33, height: 33, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _CancelRequestCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelRequestCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _RequestCardShell(
      onTap: onTap,
      height: 65,
      borderColor: AppColors.Error,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.close, size: 24, color: AppColors.Error),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Cancel Request',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.TinyBody.copyWith(color: AppColors.Error, height: 1),
            ),
          ),
          SvgPicture.asset(
            'assets/icons/arrow_go_blue.svg',
            width: 33,
            height: 33,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(AppColors.Error, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}

class _RequestCardShell extends StatelessWidget {
  final Widget child;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final VoidCallback onTap;

  const _RequestCardShell({
    required this.child,
    required this.height,
    required this.padding,
    required this.onTap,
    this.borderColor = AppColors.PrimaryLighter,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
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
            border: Border.all(color: borderColor, width: 1.4),
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

class _OutlineButtonCard extends StatelessWidget {
  final String title;
  final String iconAsset;
  final VoidCallback onTap;

  const _OutlineButtonCard({required this.title, required this.iconAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _RequestCardShell(
      onTap: onTap,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary, height: 1)),
          const SizedBox(width: 8),
          SvgPicture.asset(iconAsset, width: 20, height: 20),
        ],
      ),
    );
  }
}

class _RequestLabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _RequestLabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.TinyBodyBold.copyWith(color: AppColors.Primary)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _EditableLocationField extends StatelessWidget {
  final TextEditingController controller;

  const _EditableLocationField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.Tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/navigate_black.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(AppColors.Accent, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 1,
              cursorColor: AppColors.Accent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: true,
                fillColor: AppColors.Tertiary,
                hoverColor: AppColors.Tertiary,
                focusColor: AppColors.Tertiary,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsTextArea extends StatelessWidget {
  final TextEditingController controller;

  const _DetailsTextArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 8,
      maxLines: 10,
      style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary),
      decoration: InputDecoration(
        hintText: 'Write here...',
        hintStyle: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter),
        filled: true,
        fillColor: AppColors.Tertiary,
        contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.Accent, width: 1.4),
        ),
      ),
    );
  }
}

class _EmergencyLine extends StatelessWidget {
  final String label;
  final String number;
  final String description;

  const _EmergencyLine({required this.label, required this.number, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$label  ', style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary)),
              TextSpan(
                text: number,
                style: AppTextStyles.TinyBodyMediumLink.copyWith(color: AppColors.Accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(description, style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter, height: 1.1)),
      ],
    );
  }
}

class _RequestOverviewCard extends StatelessWidget {
  final String location;
  final String details;
  final DateTime submittedAt;

  const _RequestOverviewCard({required this.location, required this.details, required this.submittedAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.Tertiary, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OverviewLine(label: 'Time:', value: _formatTime(submittedAt)),
          const SizedBox(height: 8),
          _OverviewLine(label: 'Location:', value: location),
          const SizedBox(height: 8),
          _OverviewLine(
            label: 'Details:',
            value: details.isEmpty
                ? 'The elevators on Floor 2 don’t seem to be working, and I need assistance to use the stairs.'
                : details,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.hour)}:${two(date.minute)}';
  }
}

class _OverviewLine extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label ', style: AppTextStyles.TinyBodyBold.copyWith(color: AppColors.Primary)),
          TextSpan(text: value, style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary)),
        ],
      ),
    );
  }
}
