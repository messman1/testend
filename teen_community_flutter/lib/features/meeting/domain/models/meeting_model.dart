/// 모임 모델
class MeetingModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime meetingDate;
  final int maxParticipants;
  final List<String> participants;
  final String creatorId;
  final String creatorNickname;
  final DateTime createdAt;

  const MeetingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.meetingDate,
    required this.maxParticipants,
    required this.participants,
    required this.creatorId,
    required this.creatorNickname,
    required this.createdAt,
  });

  /// 참가 가능 여부
  bool get canJoin => participants.length < maxParticipants;

  /// 참가 인원 문자열
  String get participantInfo => '${participants.length}/$maxParticipants명';

  /// JSON으로부터 생성
  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      location: json['location'] as String,
      meetingDate: DateTime.parse(json['meeting_date'] as String),
      maxParticipants: json['max_participants'] as int,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      creatorId: json['creator_id'] as String,
      creatorNickname: json['creator_nickname'] as String? ?? '익명',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'meeting_date': meetingDate.toIso8601String(),
      'max_participants': maxParticipants,
      'participants': participants,
      'creator_id': creatorId,
      'creator_nickname': creatorNickname,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 복사본 생성
  MeetingModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    DateTime? meetingDate,
    int? maxParticipants,
    List<String>? participants,
    String? creatorId,
    String? creatorNickname,
    DateTime? createdAt,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      meetingDate: meetingDate ?? this.meetingDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participants: participants ?? this.participants,
      creatorId: creatorId ?? this.creatorId,
      creatorNickname: creatorNickname ?? this.creatorNickname,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 모임 카테고리
enum MeetingCategory {
  study('study', '📚', '공부'),
  game('game', '🎮', '게임'),
  sports('sports', '⚽', '운동'),
  hobby('hobby', '🎨', '취미'),
  etc('etc', '💬', '기타');

  final String code;
  final String icon;
  final String label;

  const MeetingCategory(this.code, this.icon, this.label);

  static MeetingCategory? fromCode(String code) {
    try {
      return MeetingCategory.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }
}
