import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/map_place_model.dart';
import '../../screens/map/search_results_screen.dart';
import '../../theme/app_styles.dart';
import '../../widgets/buttons/button.dart';

enum _ReportIssueStep { form, submitted }

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(
    text: _location,
  );

  _ReportIssueStep _step = _ReportIssueStep.form;
  String? _selectedIssueType;
  String _selectedElevator = 'Elevator 1 - Floor 1, Building 1, Iscte-IUL Lisbon Campus';
  DateTime? _submittedAt;
  bool _photoSelected = false;
  static const String _location = 'ISCTE-IUL, Building 1, Floor 2, Room 1...';

  final List<String> _issueTypes = const [
    'Elevators / Lifts',
    'Ramp access',
    'Door access',
    'Accessible bathroom',
    'Other accessibility issue',
  ];

  final List<String> _elevators = const [
    'Elevator 1 - Floor 1, Building 1, Iscte-IUL Lisbon Campus',
    'Elevator 2 - Floor 0, Building 1, Iscte-IUL Lisbon Campus',
    'Elevator 3 - Floor 2, Building 2, Iscte-IUL Lisbon Campus',
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitReport() {
    setState(() {
      _selectedIssueType ??= 'Elevators / Lifts';
      _submittedAt = DateTime.now();
      _step = _ReportIssueStep.submitted;
    });
  }

  Future<void> _openLocationSelector() async {
    final place = await Navigator.push<MapPlace>(
      context,
      MaterialPageRoute(
        builder: (_) => MapSearchResultsScreen(
          currentLatitude: 38.7477,
          currentLongitude: -9.1530,
          initialQuery: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
        ),
      ),
    );

    if (place == null || !mounted) return;

    setState(() {
      _locationController.text = place.name;
    });
  }

  Future<void> _openIssueTypeSelector() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.White,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SelectorSheet(
        title: 'Choose a type of issue',
        options: _issueTypes,
        selected: _selectedIssueType,
      ),
    );

    if (selected != null) {
      setState(() => _selectedIssueType = selected);
    }
  }

  Future<void> _openElevatorSelector() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.White,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SelectorSheet(
        title: 'Select the elevator',
        options: _elevators,
        selected: _selectedElevator,
      ),
    );

    if (selected != null) {
      setState(() => _selectedElevator = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Background,
      body: SafeArea(
        bottom: false,
        child: _step == _ReportIssueStep.form
            ? _ReportIssueForm(
                selectedIssueType: _selectedIssueType,
                selectedElevator: _selectedElevator,
                detailsController: _detailsController,
                location: _locationController.text.trim().isEmpty
                    ? _location
                    : _locationController.text.trim(),
                photoSelected: _photoSelected,
                onBack: () => Navigator.pop(context),
                onOpenIssueSelector: _openIssueTypeSelector,
                onOpenElevatorSelector: _openElevatorSelector,
                onOpenLocationSelector: _openLocationSelector,
                onPhotoTap: () => setState(() => _photoSelected = true),
                onSubmit: _submitReport,
              )
            : _ReportSubmitted(
                selectedIssueType: _selectedIssueType ?? 'Elevators / Lifts',
                selectedElevator: _selectedElevator,
                location: _locationController.text.trim().isEmpty
                    ? _location
                    : _locationController.text.trim(),
                details: _detailsController.text.trim(),
                submittedAt: _submittedAt ?? DateTime.now(),
                photoSelected: _photoSelected,
                onBack: () => setState(() => _step = _ReportIssueStep.form),
                onReturnHome: () => Navigator.pop(context),
              ),
      ),
    );
  }
}

class _ReportIssueForm extends StatelessWidget {
  final String? selectedIssueType;
  final String selectedElevator;
  final TextEditingController detailsController;
  final String location;
  final bool photoSelected;
  final VoidCallback onBack;
  final VoidCallback onOpenIssueSelector;
  final VoidCallback onOpenElevatorSelector;
  final VoidCallback onOpenLocationSelector;
  final VoidCallback onPhotoTap;
  final VoidCallback onSubmit;

  const _ReportIssueForm({
    required this.selectedIssueType,
    required this.selectedElevator,
    required this.detailsController,
    required this.location,
    required this.photoSelected,
    required this.onBack,
    required this.onOpenIssueSelector,
    required this.onOpenElevatorSelector,
    required this.onOpenLocationSelector,
    required this.onPhotoTap,
    required this.onSubmit,
  });

  bool get _isElevatorIssue => selectedIssueType == 'Elevators / Lifts';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        
        _ReportTopBar(title: 'Report Issue', onBack: onBack),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Reporting a Accessibility Issue',
            style: AppTextStyles.BodyMedium.copyWith(color: AppColors.Primary),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Add a photo (optional)',
            style: AppTextStyles.BodyMedium.copyWith(color: AppColors.Primary),
          ),
        ),
        const SizedBox(height: 8),
        _AddPhotoArea(selected: photoSelected, onTap: onPhotoTap),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReportLabeledField(
                label: 'Type of issue',
                child: _ReportSelectBox(
                  text: selectedIssueType ?? 'Choose a type of issue',
                  faded: selectedIssueType == null,
                  onTap: onOpenIssueSelector,
                ),
              ),
              const SizedBox(height: 24),
              if (_isElevatorIssue) ...[
                _ReportLabeledField(
                  label: 'Select the elevator',
                  child: _ReportSelectBox(
                    text: selectedElevator,
                    iconAsset: 'assets/icons/elevator.svg',
                    iconColor: AppColors.CategoryMagenta,
                    onTap: onOpenElevatorSelector,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _ReportLabeledField(
                label: 'Location of the issue',
                child: _ReportReadOnlyBox(
                  text: location,
                  iconAsset: 'assets/icons/navigate_black.svg',
                  iconColor: AppColors.Accent,
                  onTap: onOpenLocationSelector,
                ),
              ),
              const SizedBox(height: 24),
              _ReportLabeledField(
                label: 'Describe the issue (e.g elevator not working)',
                child: _ReportTextArea(controller: detailsController),
              ),
              const SizedBox(height: 32),
              Center(
                child: AppButton(text: 'Send Report', onPressed: onSubmit),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportSubmitted extends StatelessWidget {
  final String selectedIssueType;
  final String selectedElevator;
  final String location;
  final String details;
  final DateTime submittedAt;
  final bool photoSelected;
  final VoidCallback onBack;
  final VoidCallback onReturnHome;

  const _ReportSubmitted({
    required this.selectedIssueType,
    required this.selectedElevator,
    required this.location,
    required this.details,
    required this.submittedAt,
    required this.photoSelected,
    required this.onBack,
    required this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        
        _ReportTopBar(title: 'Report Submitted', onBack: onBack),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Report submitted successfully',
                    style: AppTextStyles.BodyMedium.copyWith(color: AppColors.Primary),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset('assets/icons/green_check.svg', width: 20, height: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your report has been sent to the appropriate support services for review and follow-up.',
                style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary, height: 1.2),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Status: ', style: AppTextStyles.TinyBodyBold),
                    TextSpan(text: 'Your report is being analyzed', style: AppTextStyles.TinyBody),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Report Overview', style: AppTextStyles.BodyMedium.copyWith(color: AppColors.Primary)),
              const SizedBox(height: 16),
              _ReportOverviewCard(
                selectedIssueType: selectedIssueType,
                selectedElevator: selectedElevator,
                location: location,
                details: details,
                submittedAt: submittedAt,
                photoSelected: photoSelected,
              ),
              const SizedBox(height: 32),
              Center(
                child: AppButton(text: 'Return to Home', onPressed: onReturnHome),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _ReportTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _ReportTopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBack,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
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
          Text(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: AppTextStyles.Heading2.copyWith(
              color: AppColors.Primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoArea extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _AddPhotoArea({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 224,
        width: double.infinity,
        color: AppColors.Tertiary,
        alignment: Alignment.center,
        child: selected
            ? Image.asset(
                'assets/images/elevator_report.png',
                width: double.infinity,
                height: 224,
                fit: BoxFit.cover,
              )
            : Container(
                width: 67,
                height: 67,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.Tertiary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.Accent, width: 1.4),
                ),
                child: SvgPicture.asset('assets/icons/plus_blue.svg', width: 36, height: 36),
              ),
      ),
    );
  }
}

class _ReportLabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _ReportLabeledField({required this.label, required this.child});

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

class _ReportSelectBox extends StatelessWidget {
  final String text;
  final String? iconAsset;
  final Color? iconColor;
  final bool faded;
  final VoidCallback onTap;

  const _ReportSelectBox({
    required this.text,
    required this.onTap,
    this.iconAsset,
    this.iconColor,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 60,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(color: AppColors.Tertiary, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            if (iconAsset != null) ...[
              SvgPicture.asset(
                iconAsset!,
                width: 20,
                height: 20,
                colorFilter: iconColor != null ? ColorFilter.mode(iconColor!, BlendMode.srcIn) : null,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.TinyBody.copyWith(
                  color: faded ? AppColors.PrimaryLighter : AppColors.Primary,
                  fontWeight: faded ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.Primary, size: 30),
          ],
        ),
      ),
    );
  }
}

class _ReportReadOnlyBox extends StatelessWidget {
  final String text;
  final String? iconAsset;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _ReportReadOnlyBox({
    required this.text,
    this.iconAsset,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 60,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.Tertiary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (iconAsset != null) ...[
              SvgPicture.asset(
                iconAsset!,
                width: 20,
                height: 20,
                colorFilter: iconColor != null
                    ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                    : null,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.TinyBody.copyWith(
                  color: AppColors.Primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTextArea extends StatelessWidget {
  final TextEditingController controller;

  const _ReportTextArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 6,
      maxLines: 8,
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

class _ReportOverviewCard extends StatelessWidget {
  final String selectedIssueType;
  final String selectedElevator;
  final String location;
  final String details;
  final DateTime submittedAt;
  final bool photoSelected;

  const _ReportOverviewCard({
    required this.selectedIssueType,
    required this.selectedElevator,
    required this.location,
    required this.details,
    required this.submittedAt,
    required this.photoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.Tertiary, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoSelected) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/elevator_report.png',
                height: 134,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          _OverviewLine(label: 'Time:', value: _formatSubmittedAt(submittedAt)),
          const SizedBox(height: 6),
          _OverviewLine(label: 'Type of issue:', value: selectedIssueType),
          const SizedBox(height: 6),
          _OverviewLine(label: 'Elevator:', value: selectedElevator),
          const SizedBox(height: 6),
          _OverviewLine(label: 'Location:', value: location),
          const SizedBox(height: 6),
          _OverviewLine(label: 'Details:', value: details.isEmpty ? 'No details provided.' : details),
        ],
      ),
    );
  }

  String _formatSubmittedAt(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
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

class _SelectorSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;

  const _SelectorSheet({required this.title, required this.options, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 5,
                decoration: BoxDecoration(color: AppColors.Secondary, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.Heading2.copyWith(color: AppColors.Primary, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            for (final option in options) ...[
              _SelectorOption(
                title: option,
                selected: option == selected,
                onTap: () => Navigator.pop(context, option),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectorOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SelectorOption({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.Tertiary,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: AppColors.Accent, width: 1.4) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.Body.copyWith(color: AppColors.Primary),
              ),
            ),
            if (selected) const Icon(Icons.check, color: AppColors.Accent, size: 22),
          ],
        ),
      ),
    );
  }
}
