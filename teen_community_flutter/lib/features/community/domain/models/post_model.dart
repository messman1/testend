/// 게시글 모델
class PostModel {
  final String id;
  final String userId;
  final String userNickname;
  final String title;
  final String content;
  final String type;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.userNickname,
    required this.title,
    required this.content,
    required this.type,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON으로부터 생성
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userNickname: json['user_nickname'] as String? ?? '익명',
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      imageUrl: json['image_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_nickname': userNickname,
      'title': title,
      'content': content,
      'type': type,
      'image_url': imageUrl,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 복사본 생성
  PostModel copyWith({
    String? id,
    String? userId,
    String? userNickname,
    String? title,
    String? content,
    String? type,
    String? imageUrl,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 게시글 타입
enum PostType {
  general('general', '💬', '일반'),
  question('question', '❓', '질문'),
  review('review', '⭐', '후기'),
  meetup('meetup', '👥', '모임');

  final String code;
  final String icon;
  final String label;

  const PostType(this.code, this.icon, this.label);

  static PostType? fromCode(String code) {
    try {
      return PostType.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }
}
