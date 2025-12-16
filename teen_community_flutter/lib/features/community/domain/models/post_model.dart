
enum PostType {
  normal,
  newOpen, // 'new' from NodeJS
  review, // 'review' from NodeJS
  event, // 'event' from NodeJS
}

class PostModel {
  final String id;
  final String title;
  final String content;
  final String authorNickname;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final PostType type;
  final String? imageUrl;
  final bool isLiked; // 로컬 사용자의 좋아요 여부 (옵션)

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorNickname,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.type,
    this.imageUrl,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      authorNickname: json['author_nickname'] ?? '익명',
      createdAt: DateTime.parse(json['created_at']),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      type: _parseType(json['type']),
      imageUrl: json['image_url'],
      isLiked: json['is_liked'] ?? false, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'type': typeToString(type),
      'image_url': imageUrl,
    };
  }

  static PostType _parseType(String? type) {
    switch (type) {
      case 'new':
        return PostType.newOpen;
      case 'review':
        return PostType.review;
      case 'event':
        return PostType.event;
      case 'general':
      default:
        return PostType.normal;
    }
  }

  static String typeToString(PostType type) {
     switch (type) {
      case PostType.newOpen:
        return 'new';
      case PostType.review:
        return 'review';
      case PostType.event:
        return 'event';
      default:
        return 'general'; 
    }
  }
}
