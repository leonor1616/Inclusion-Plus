import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../state/community_post_store.dart';
import '../../theme/app_styles.dart';
import '../../widgets/buttons/button.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _responseController = TextEditingController();
  final CommunityPostStore _store = CommunityPostStore.instance;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _responseController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final authorName = auth.user?.fullName?.trim();
    // Comments are appended locally immediately; backend persistence is best
    // effort for posts that came from the backend.
    await _store.addComment(
      postId: widget.postId,
      content: text,
      token: auth.token,
      authorName: authorName != null && authorName.isNotEmpty ? authorName : 'Francisco Soares',
    );
    _responseController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final post = _store.postById(widget.postId);

        if (post == null) {
          return Scaffold(
            backgroundColor: AppColors.Background,
            body: SafeArea(
              child: Column(
                children: [
                  _PostTopBar(title: 'Post Detail', onBack: () => Navigator.pop(context)),
                  const Spacer(),
                  Text('Post not found.', style: AppTextStyles.Body),
                  const Spacer(),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.Background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                
                _PostTopBar(title: 'Post Detail', onBack: () => Navigator.pop(context)),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      _FullPostCard(post: post),
                      const SizedBox(height: 32),
                      Text('Answers', style: AppTextStyles.BodyBold),
                      const SizedBox(height: 16),
                      for (final comment in post.comments) ...[
                        _AnswerTile(comment: comment),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                _CommentComposer(
                  controller: _responseController,
                  onSubmit: _submitComment,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



class _PostTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _PostTopBar({required this.title, required this.onBack});

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

class _FullPostCard extends StatelessWidget {
  final CommunityPost post;

  const _FullPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.White,
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
                height: 160,
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
              Text(post.commentsCount.toString(), style: AppTextStyles.TinyBody.copyWith(color: AppColors.Accent)),
              const Spacer(),
              SvgPicture.asset(
                'assets/icons/share.svg',
                width: 22,
                height: 22,
                colorFilter: const ColorFilter.mode(AppColors.Accent, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(post.sharesCount.toString(), style: AppTextStyles.TinyBody.copyWith(color: AppColors.Accent)),
            ],
          ),
        ],
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
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }
}

class _AnswerTile extends StatelessWidget {
  final CommunityComment comment;

  const _AnswerTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.Tertiary, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(comment.authorName, style: AppTextStyles.TinyBodyBold),
              const Spacer(),
              Text(
                _formatPostDate(comment.createdAt),
                style: AppTextStyles.TinyBody.copyWith(color: AppColors.PrimaryLighter),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: AppTextStyles.TinyBody.copyWith(
              color: AppColors.Primary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPostDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
  }
}

class _CommentComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _CommentComposer({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.White,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.Tertiary,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Write a response',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: true,
                        fillColor: AppColors.Tertiary,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintStyle: AppTextStyles.Body.copyWith(color: AppColors.PrimaryLighter),
                      ),
                      cursorColor: AppColors.Primary,
                      style: AppTextStyles.Body.copyWith(color: AppColors.Primary),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/mic_rounded.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(AppColors.Primary, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          AppButton(
            text: 'Post',
            iconAsset: 'assets/icons/navigate_white.svg',
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
