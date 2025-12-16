/// 장소 카테고리
enum PlaceCategory {
  karaoke('karaoke', '코인노래방', '🎤'),
  escape('escape', '방탈출', '🎯'),
  board('board', '보드게임', '🎲'),
  movie('movie', '영화관', '🎬'),
  cafe('cafe', '북카페', '📚');

  final String code;
  final String label;
  final String icon;

  const PlaceCategory(this.code, this.label, this.icon);

  static PlaceCategory? fromCode(String code) {
    return PlaceCategory.values.firstWhere(
      (cat) => cat.code == code,
      orElse: () => PlaceCategory.cafe,
    );
  }
}

/// 장소 모델
class PlaceModel {
  final String id;
  final String name;
  final PlaceCategory category;
  final String location; // 예: "역삼동"
  final String address; // 전체 주소
  final String phone;
  final String distance; // 예: "1.2km"
  final String? thumbnail;
  final String url; // 카카오맵 URL
  final double x; // 경도
  final double y; // 위도
  final String? categoryDetail; // 카카오 카테고리 상세
  final double rating;
  final int reviewCount;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.address,
    this.phone = '',
    required this.distance,
    this.thumbnail,
    required this.url,
    required this.x,
    required this.y,
    this.categoryDetail,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  /// JSON에서 PlaceModel 생성
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: PlaceCategory.fromCode(json['category'] as String) ??
          PlaceCategory.cafe,
      location: json['location'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String? ?? '',
      distance: json['distance'] as String,
      thumbnail: json['thumbnail'] as String?,
      url: json['url'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      categoryDetail: json['categoryDetail'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  /// PlaceModel을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.code,
      'location': location,
      'address': address,
      'phone': phone,
      'distance': distance,
      'thumbnail': thumbnail,
      'url': url,
      'x': x,
      'y': y,
      'categoryDetail': categoryDetail,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  @override
  String toString() {
    return 'PlaceModel(id: $id, name: $name, category: ${category.label}, distance: $distance, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
