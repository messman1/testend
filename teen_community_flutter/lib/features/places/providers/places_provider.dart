import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/kakao_place_repository.dart';
import '../domain/models/place_model.dart';

/// KakaoPlaceRepository Provider
final kakaoPlaceRepositoryProvider = Provider<KakaoPlaceRepository>((ref) {
  return KakaoPlaceRepository();
});

/// 인기 장소 목록 Provider (위치 기반)
final popularPlacesProvider = FutureProvider.family<List<PlaceModel>, LocationParams>(
  (ref, params) async {
    final repository = ref.watch(kakaoPlaceRepositoryProvider);

    return await repository.getAllPlaces(
      x: params.longitude,
      y: params.latitude,
      sizePerCategory: params.sizePerCategory,
    );
  },
);

/// 카테고리별 장소 목록 Provider
final categoryPlacesProvider = FutureProvider.family<List<PlaceModel>, CategoryParams>(
  (ref, params) async {
    final repository = ref.watch(kakaoPlaceRepositoryProvider);

    return await repository.searchByCategory(
      category: params.category,
      x: params.longitude,
      y: params.latitude,
      size: params.size,
      sortType: params.sortType,
    );
  },
);

/// 위치 파라미터
class LocationParams {
  final double latitude;
  final double longitude;
  final int sizePerCategory;

  const LocationParams({
    required this.latitude,
    required this.longitude,
    this.sizePerCategory = 5,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationParams &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.sizePerCategory == sizePerCategory;
  }

  @override
  int get hashCode =>
      latitude.hashCode ^ longitude.hashCode ^ sizePerCategory.hashCode;
}

/// 카테고리 파라미터
class CategoryParams {
  final PlaceCategory category;
  final double latitude;
  final double longitude;
  final int size;
  final PlaceSortType sortType;

  const CategoryParams({
    required this.category,
    required this.latitude,
    required this.longitude,
    this.size = 10,
    this.sortType = PlaceSortType.rating,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryParams &&
        other.category == category &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.size == size &&
        other.sortType == sortType;
  }

  @override
  int get hashCode =>
      category.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      size.hashCode ^
      sortType.hashCode;
}
