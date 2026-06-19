import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../state/community_post_store.dart';
import '../../theme/app_styles.dart';
import '../../widgets/app_header.dart';
import '../../widgets/search_bar.dart';
import 'community_new_post_screen.dart';
import 'post_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final CommunityPostStore _store = CommunityPostStore.instance;
  String _selectedTag = 'All';

  TextStyle get _sectionTitle => AppTextStyles.Heading2.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.Primary,
      );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final token = context.read<AuthProvider>().token;
      _store.loadBackendPosts(token: token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final posts = _store.postsFor(_selectedTag, limit: 4);

        return Scaffold(
          backgroundColor: AppColors.Background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
            
                const SizedBox(height: 8),
                const AppHeader(
                  logoAsset: 'assets/logos/inclusion_logo_purple.svg',
                ),
                const SizedBox(height: 16),
                const AppSearchBar(),
                const SizedBox(height: 16),
                Text('Community Information', style: _sectionTitle),
                const SizedBox(height: 16),
                const _CommunityInfoRow(),
                const SizedBox(height: 16),
                Text('Want to share something?', style: AppTextStyles.BodyBold),
                const SizedBox(height: 16),
                _CreatePostCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CommunityNewPostScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text('Posts from users', style: AppTextStyles.BodyBold),
                const SizedBox(height: 24),
                Text('Showing 21 Results', style: AppTextStyles.TinyBodyBold),
                const SizedBox(height: 16),
                _TagRow(
                  selectedTag: _selectedTag,
                  onSelected: (tag) => setState(() => _selectedTag = tag),
                ),
                const SizedBox(height: 16),
                const _FilterSortRow(),
                const SizedBox(height: 16),
                for (int index = 0; index < posts.length; index++) ...[
                  _PostPreviewCard(
                    post: posts[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(postId: posts[index].id),
                        ),
                      );
                    },
                  ),
                  if (index != posts.length - 1) const SizedBox(height: 16),
                ],
                if (posts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No posts in this category yet.',
                        style: AppTextStyles.TinyBody.copyWith(
                          color: AppColors.PrimaryLighter,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _CommunityInfoRow extends StatelessWidget {
  const _CommunityInfoRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 117,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _CommunityInfoAction(
            label: 'Buddy\nProgram',
            iconAsset: 'assets/icons/person_waving_white.svg',
            color: AppColors.CategoryOrange,
          ),
          SizedBox(width: 24),
          _CommunityInfoAction(
            label: 'Events',
            iconAsset: 'assets/icons/calendar.svg',
            color: AppColors.CategoryMagenta,
          ),
          SizedBox(width: 24),
          _CommunityInfoAction(
            label: 'Activities',
            iconAsset: 'assets/icons/smile.svg',
            color: AppColors.CategoryPurple,
          ),
        ],
      ),
    );
  }
}

class _CommunityInfoAction extends StatelessWidget {
  final String label;
  final String iconAsset;
  final Color color;

  const _CommunityInfoAction({
    required this.label,
    required this.iconAsset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: SvgPicture.asset(
              iconAsset,
              width: 33,
              height: 33,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                AppColors.White,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.TinyBody.copyWith(
              color: AppColors.Primary,
              height: 1.16,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatePostCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePostCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _WhiteActionCard(
      title: 'Create a Post',
      leadingAsset: 'assets/icons/plus_blue.svg',
      onTap: onTap,
    );
  }
}

class _TagRow extends StatelessWidget {
  final String selectedTag;
  final ValueChanged<String> onSelected;

  const _TagRow({required this.selectedTag, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const tags = ['All', 'Question', 'Review', 'Advice'];

    return SizedBox(
      height: 32,
      child: Row(
        children: [
          for (int index = 0; index < tags.length; index++) ...[
            _TagChip(
              label: tags[index],
              selectedColor: _colorForTag(tags[index]),
              selected: selectedTag == tags[index],
              onTap: () => onSelected(tags[index]),
            ),
            if (index != tags.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Color _colorForTag(String tag) {
    return switch (tag) {
      'All' => AppColors.Accent,
      'Question' => AppColors.CategoryMagenta,
      'Review' => AppColors.CategoryPurple,
      'Advice' => AppColors.CategoryOrange,
      _ => AppColors.Accent,
    };
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color selectedColor;
  final bool selected;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.selectedColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
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
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: AppTextStyles.TinyBody.copyWith(
              color: selected ? AppColors.White : AppColors.Primary,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSortRow extends StatelessWidget {
  const _FilterSortRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SmallOutlinedButton(
            label: 'Filter',
            iconAsset: 'assets/icons/filter.svg',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SmallOutlinedButton(
            label: 'Sort by',
            iconAsset: 'assets/icons/sort.svg',
          ),
        ),
      ],
    );
  }
}

class _SmallOutlinedButton extends StatelessWidget {
  final String label;
  final String iconAsset;

  const _SmallOutlinedButton({required this.label, required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.Body.copyWith(color: AppColors.Primary)),
          const SizedBox(width: 3),
          SvgPicture.asset(
            iconAsset,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(AppColors.Primary, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}

class _PostPreviewCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onTap;

  const _PostPreviewCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${post.authorName} ${post.tag} post',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 148),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.Tertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.TinyBodyBold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            post.tag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.TinyBodyMediumLink.copyWith(
                              color: _tagColor(post.tag),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatPostDate(post.createdAt),
                    style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter),
                  ),
                ],
              ),
              if (post.tag == 'Review' && post.rating != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${post.rating} stars',
                      style: AppTextStyles.TinyBody.copyWith(color: AppColors.Primary),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/icons/star_filled.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(AppColors.Accent, BlendMode.srcIn),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.TinyBody.copyWith(
                  color: AppColors.Primary,
                  height: 1.25,
                ),
              ),
              if (post.imageAsset != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    post.imageAsset!,
                    height: 126,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/messages-3.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(AppColors.Accent, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.commentsCount.toString(),
                    style: AppTextStyles.TinyBody.copyWith(color: AppColors.Accent),
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    'assets/icons/share.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(AppColors.Accent, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.sharesCount.toString(),
                    style: AppTextStyles.TinyBody.copyWith(color: AppColors.Accent),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _tagColor(String tag) {
    return switch (tag) {
      'Question' => AppColors.CategoryMagenta,
      'Review' => AppColors.CategoryPurple,
      'Advice' => AppColors.CategoryOrange,
      _ => AppColors.Accent,
    };
  }

  String _formatPostDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds < 60 && date.year == now.year) {
      return '${difference.inSeconds.clamp(1, 59)} seconds ago';
    }
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
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
            border: Border.all(color: AppColors.PrimaryLighter, width: 1.4),
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
              SvgPicture.asset(
                leadingAsset,
                width: 33,
                height: 33,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(AppColors.Accent, BlendMode.srcIn),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
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
        ),
      ),
    );
  }
}
