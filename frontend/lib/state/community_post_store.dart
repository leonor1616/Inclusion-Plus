import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

class CommunityComment {
  final String authorName;
  final String content;
  final DateTime createdAt;

  const CommunityComment({
    required this.authorName,
    required this.content,
    required this.createdAt,
  });
}

class CommunityPost {
  final int id;
  final String authorName;
  final String tag;
  final String content;
  final DateTime createdAt;
  final int commentsCount;
  final int sharesCount;
  final int? rating;
  final String? imageAsset;
  final List<CommunityComment> comments;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.tag,
    required this.content,
    required this.createdAt,
    required this.commentsCount,
    required this.sharesCount,
    this.rating,
    this.imageAsset,
    this.comments = const [],
  });

  CommunityPost copyWith({
    int? id,
    String? authorName,
    String? tag,
    String? content,
    DateTime? createdAt,
    int? commentsCount,
    int? sharesCount,
    int? rating,
    String? imageAsset,
    List<CommunityComment>? comments,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      tag: tag ?? this.tag,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      rating: rating ?? this.rating,
      imageAsset: imageAsset ?? this.imageAsset,
      comments: comments ?? this.comments,
    );
  }
}

class CommunityPostStore extends ChangeNotifier {
  CommunityPostStore._();

  static final CommunityPostStore instance = CommunityPostStore._();

  int _nextLocalId = 1000;

  final List<CommunityPost> _posts = [
    CommunityPost(
      id: 1,
      authorName: 'João G.',
      tag: 'Question',
      content:
          'Hello, I am thinking of going to X venue but I wonder if it is accessible for disabled people.',
      createdAt: DateTime(2025, 12, 6, 11, 34),
      commentsCount: 930,
      sharesCount: 1234,
      imageAsset: 'assets/images/community_post_park.jpg',
      comments: [
        CommunityComment(
          authorName: 'Anabela J.',
          content:
              'Yes, it is accessible! I went there a couple of days ago, and had a pretty good experience.',
          createdAt: DateTime(2025, 12, 6, 11, 34),
        ),
        CommunityComment(
          authorName: 'Richard M.',
          content:
              'Yes, it is accessible! I went there a couple of days ago, and had a pretty good experience.',
          createdAt: DateTime(2025, 12, 6, 11, 34),
        ),
      ],
    ),
  ];

  List<CommunityPost> postsFor(String selectedTag, {int limit = 4}) {
    final filtered = selectedTag == 'All'
        ? List<CommunityPost>.from(_posts)
        : _posts.where((post) => post.tag == selectedTag).toList();

    filtered.sort((a, b) {
      final dateCompare = b.createdAt.compareTo(a.createdAt);
      if (dateCompare != 0) return dateCompare;
      return b.id.compareTo(a.id);
    });

    return filtered.take(limit).toList();
  }

  Future<void> loadBackendPosts({String? token}) async {
    // The visual prototype keeps the feed deterministic: only the original
    // seed post and posts created during the current session are shown.
    return;
  }

  Future<CommunityPost> createPost({
    required String tag,
    required String content,
    required bool hasImage,
    required String authorName,
    int? rating,
    String? token,
  }) async {
    final createdAt = DateTime.now();
    int id = _nextLocalId++;

    if (token != null && token.isNotEmpty) {
      try {
        await ApiService.createCommunityPost(
          token: token,
          postType: tag.toLowerCase(),
          content: content,
          rating: tag == 'Review' ? rating : null,
          imageUrl: hasImage ? 'community_post_park.jpg' : null,
        );
      } catch (_) {
        // The UI prototype keeps the post locally if the backend is unavailable.
      }
    }

    final trimmedAuthor = authorName.trim();
    final post = CommunityPost(
      id: id,
      authorName: trimmedAuthor.isEmpty ? 'Francisco Soares' : trimmedAuthor,
      tag: tag,
      content: content.trim().isEmpty ? 'No description provided.' : content.trim(),
      createdAt: createdAt,
      commentsCount: 0,
      sharesCount: 0,
      rating: tag == 'Review' ? rating : null,
      imageAsset: hasImage ? 'assets/images/community_post_park.jpg' : null,
    );

    _posts.insert(0, post);
    notifyListeners();
    return post;
  }

  Future<void> addComment({
    required int postId,
    required String content,
    required String authorName,
    String? token,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    if (token != null && token.isNotEmpty && postId < 1000) {
      try {
        await ApiService.createPostComment(
          token: token,
          postId: postId,
          content: trimmed,
        );
      } catch (_) {
        // Keep prototype comments locally if the backend is unavailable.
      }
    }

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    final post = _posts[index];
    final trimmedAuthor = authorName.trim();
    final comments = [
      ...post.comments,
      CommunityComment(
        authorName: trimmedAuthor.isEmpty ? 'Francisco Soares' : trimmedAuthor,
        content: trimmed,
        createdAt: DateTime.now(),
      ),
    ];

    _posts[index] = post.copyWith(
      comments: comments,
      commentsCount: post.commentsCount + 1,
    );
    notifyListeners();
  }

  CommunityPost? postById(int id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (_) {
      return null;
    }
  }

  CommunityPost? _fromBackend(Map<String, dynamic> json) {
    final postType = json['post_type']?.toString();
    if (postType == null) return null;

    final tag = switch (postType) {
      'question' => 'Question',
      'review' => 'Review',
      'advice' => 'Advice',
      _ => 'Question',
    };

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json['created_at'].toString()).toLocal();
    } catch (_) {
      createdAt = DateTime.now();
    }

    final imageUrl = json['image_url']?.toString();

    return CommunityPost(
      id: int.tryParse(json['id'].toString()) ?? _nextLocalId++,
      authorName: json['author_name']?.toString() ?? 'User',
      tag: tag,
      content: json['content']?.toString() ?? '',
      createdAt: createdAt,
      commentsCount: int.tryParse(json['comments_count']?.toString() ?? '') ?? 0,
      sharesCount: 0,
      rating: json['rating'] == null ? null : int.tryParse(json['rating'].toString()),
      imageAsset: imageUrl == null || imageUrl.isEmpty
          ? null
          : 'assets/images/community_post_park.jpg',
    );
  }
}
