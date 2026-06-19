import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../models/map_place_model.dart';
import '../../screens/map/search_results_screen.dart';
import '../../state/auth_provider.dart';
import '../../state/community_post_store.dart';
import '../../theme/app_styles.dart';
import '../../widgets/buttons/button.dart';
import '../../widgets/search_bar.dart';

class CommunityNewPostScreen extends StatefulWidget {
  const CommunityNewPostScreen({super.key});

  @override
  State<CommunityNewPostScreen> createState() => _CommunityNewPostScreenState();
}

class _CommunityNewPostScreenState extends State<CommunityNewPostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedTag = 'Question';
  int _rating = 1;
  bool _imageSelected = false;
  bool _published = false;
  bool _isPublishing = false;
  MapPlace? _selectedPlace;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _selectTag(String tag) {
    setState(() {
      _selectedTag = tag;
      if (tag == 'Review' && _rating < 1) {
        _rating = 1;
      }
    });
  }

  Future<void> _selectLocation() async {
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
      _selectedPlace = place;
      _locationController.text = place.name;
    });
  }

  Future<void> _publishPost() async {
    if (_isPublishing) return;
    FocusScope.of(context).unfocus();
    setState(() => _isPublishing = true);

    final auth = context.read<AuthProvider>();
    final authorName = auth.user?.fullName?.trim();
    await CommunityPostStore.instance.createPost(
      tag: _selectedTag,
      content: _descriptionController.text,
      hasImage: _imageSelected,
      rating: _selectedTag == 'Review' ? _rating : null,
      token: auth.token,
      authorName: authorName != null && authorName.isNotEmpty ? authorName : 'Francisco Soares',
    );

    if (!mounted) return;
    setState(() {
      _isPublishing = false;
      _published = true;
    });
  }

  void _returnToCommunity() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const _NewPostStatusBar(),
                _NewPostTopBar(onBack: () => Navigator.of(context).pop()),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _SectionLabel('Choose an image (optional)'),
                ),
                const SizedBox(height: 8),
                _ImagePickerArea(
                  selected: _imageSelected,
                  onTap: () => setState(() => _imageSelected = true),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Link a location (optional)'),
                      const SizedBox(height: 8),
                      AppSearchBar(
                        hintText: _selectedPlace?.name ?? 'Search for a place',
                        controller: _locationController,
                        readOnly: true,
                        onTap: _selectLocation,
                      ),
                      const SizedBox(height: 24),
                      const _SectionLabel('Choose a topic tag'),
                      const SizedBox(height: 8),
                      _TopicTagRow(
                        selectedTag: _selectedTag,
                        onSelected: _selectTag,
                      ),
                      if (_selectedTag == 'Review') ...[
                        const SizedBox(height: 24),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Rate your accessibility experience with this\nlocation',
                                style: AppTextStyles.BodyMedium.copyWith(
                                  color: AppColors.Primary,
                                  height: 1.1,
                                ),
                              ),
                              TextSpan(
                                text: '*',
                                style: AppTextStyles.BodyMedium.copyWith(
                                  color: AppColors.Error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _StarRating(
                          value: _rating,
                          onChanged: (value) => setState(() => _rating = value),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const _SectionLabel('Write a description'),
                      const SizedBox(height: 8),
                      _DescriptionInput(controller: _descriptionController),
                      const SizedBox(height: 32),
                      Center(
                        child: AppButton(
                          text: 'Publish Post',
                          isLoading: _isPublishing,
                          onPressed: _isPublishing ? null : _publishPost,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_published)
            _PublishedOverlay(onDismiss: _returnToCommunity),
        ],
      ),
    );
  }
}

class _NewPostStatusBar extends StatelessWidget {
  const _NewPostStatusBar();

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

class _NewPostTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _NewPostTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      width: double.infinity,
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
            'New Post',
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

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.BodyMedium.copyWith(color: AppColors.Primary),
    );
  }
}

class _ImagePickerArea extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _ImagePickerArea({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 224,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: AppColors.Tertiary),
        child: selected
            ? Image.asset(
                'assets/images/community_post_park.jpg',
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
                child: SvgPicture.asset(
                  'assets/icons/plus_blue.svg',
                  width: 33,
                  height: 33,
                  fit: BoxFit.contain,
                ),
              ),
      ),
    );
  }
}

class _TopicTagRow extends StatelessWidget {
  final String selectedTag;
  final ValueChanged<String> onSelected;

  const _TopicTagRow({required this.selectedTag, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const tags = ['Question', 'Review', 'Advice'];

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          for (int index = 0; index < tags.length; index++) ...[
            _TopicTagChip(
              label: tags[index],
              selected: selectedTag == tags[index],
              selectedColor: _colorFor(tags[index]),
              onTap: () => onSelected(tags[index]),
            ),
            if (index != tags.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Color _colorFor(String tag) {
    return switch (tag) {
      'Question' => AppColors.CategoryMagenta,
      'Review' => AppColors.CategoryPurple,
      'Advice' => AppColors.CategoryOrange,
      _ => AppColors.Accent,
    };
  }
}

class _TopicTagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TopicTagChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedColor : AppColors.Tertiary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.TinyBody.copyWith(
            color: selected ? AppColors.White : AppColors.Primary,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _StarRating({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 176,
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              value.toString(),
              textAlign: TextAlign.left,
              style: AppTextStyles.Body.copyWith(color: AppColors.Primary),
            ),
          ),
          for (int index = 1; index <= 5; index++)
            SizedBox(
              width: 28,
              height: 32,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: Center(
                  child: SvgPicture.asset(
                    index <= value ? 'assets/icons/star_filled.svg' : 'assets/icons/star.svg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      index <= value ? AppColors.Accent : AppColors.Primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DescriptionInput extends StatelessWidget {
  final TextEditingController controller;

  const _DescriptionInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 8,
      maxLines: 10,
      style: AppTextStyles.Body.copyWith(color: AppColors.Primary),
      decoration: InputDecoration(
        hintText: 'Write here...',
        hintStyle: AppTextStyles.Body.copyWith(color: AppColors.PrimaryLighter),
        filled: true,
        fillColor: AppColors.Tertiary,
        contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.Accent, width: 1.4),
        ),
      ),
    );
  }
}

class _PublishedOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const _PublishedOverlay({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withValues(alpha: 0.18)),
            ),
          ),
          Center(
            child: Container(
                width: 361,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.Tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Your post was published successfully',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.BodyBold.copyWith(color: AppColors.Primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/icons/green_check.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You can see replies or edit post details under\nProfile > My Posts',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.TinyBody.copyWith(
                        color: AppColors.Primary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Return to Community',
                      onPressed: onDismiss,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
