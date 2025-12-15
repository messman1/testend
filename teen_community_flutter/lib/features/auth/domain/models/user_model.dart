/// 사용자 프로필 모델
class UserModel {
  final String id;
  final String email;
  final String nickname;
  final int level;
  final int points;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.level = 1,
    this.points = 0,
    this.badges = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 UserModel 생성
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      level: json['level'] as int? ?? 1,
      points: json['points'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// UserModel을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'level': level,
      'points': points,
      'badges': badges,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// copyWith 메서드 (불변 객체 업데이트용)
  UserModel copyWith({
    String? id,
    String? email,
    String? nickname,
    int? level,
    int? points,
    List<String>? badges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      level: level ?? this.level,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, nickname: $nickname, level: $level, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
