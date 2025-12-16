import 'package:dio/dio.dart';
import '../../../config/constants/api_constants.dart';
import '../domain/models/place_model.dart';

/// 카카오 장소 검색 리포지토리
class KakaoPlaceRepository {
  final Dio _dio;

  KakaoPlaceRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout:
                  const Duration(milliseconds: ApiConstants.connectionTimeout),
              receiveTimeout:
                  const Duration(milliseconds: ApiConstants.receiveTimeout),
            ));

  /// 청소년 비친화적 키워드 (블랙리스트)
  static const blacklistKeywords = [
    // 주류
    '주점', '술집', '바', '호프', '이자카야', '포차', '선술집',
    '맥주', '소주', '와인바', '칵테일', '펍', 'pub', 'bar',
    // 유흥
    '클럽', '나이트', '룸살롱', '단란주점', '유흥', '라운지',
    // 성인
    '성인', '19금', '19세', '어덜트', 'adult',
    // 도박
    '카지노', '도박', '베팅',
    // 담배
    '담배', '시가', '전자담배',
  ];

  /// 블랙리스트 카테고리
  static const blacklistCategories = [
    '술집', '호프', '요리주점', '나이트클럽', '유흥주점',
    '단란주점', '와인바', '칵테일바', '룸카페', '성인용품',
  ];

  /// 카테고리별 검색 키워드
  static const categoryKeywords = {
    'karaoke': '코인노래방',
    'escape': '방탈출카페',
    'board': '보드게임카페',
    'movie': '영화관',
    'cafe': '북카페',
  };

  /// 청소년 친화적인지 확인
  bool _isYouthFriendly(Map<String, dynamic> place) {
    final placeName = (place['place_name'] as String? ?? '').toLowerCase();
    final categoryName = (place['category_name'] as String? ?? '').toLowerCase();

    // 블랙리스트 키워드 체크
    for (final keyword in blacklistKeywords) {
      if (placeName.contains(keyword.toLowerCase())) {
        return false;
      }
    }

    // 블랙리스트 카테고리 체크
    for (final category in blacklistCategories) {
      if (categoryName.contains(category.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  /// 주소에서 동네 이름 추출
  String _extractLocation(String address) {
    if (address.isEmpty) return '서초구';

    final parts = address.split(' ');
    final dong = parts.firstWhere(
      (p) => p.endsWith('동'),
      orElse: () => parts.length > 2 ? parts[2] : '서초구',
    );

    return dong;
  }

  /// 거리 포맷팅 (m → km)
  String _formatDistance(String distanceStr) {
    try {
      final meters = int.parse(distanceStr);
      if (meters < 1000) {
        return '${meters}m';
      }
      return '${(meters / 1000).toStringAsFixed(1)}km';
    } catch (e) {
      return '0km';
    }
  }

  /// 카테고리별 기본 썸네일
  /// 참고: 카카오 이미지 검색 API는 CORS 이슈로 Flutter Web에서 사용 불가
  /// 추후 Supabase Storage에 직접 이미지를 관리하는 방식으로 개선 예정
  static const defaultThumbnails = {
    'karaoke': 'https://search1.kakaocdn.net/argon/130x130_85_c/Kp2KXLzRwOd',
    'escape': 'https://search1.kakaocdn.net/argon/130x130_85_c/IxxsexaSwPv',
    'board': 'https://search1.kakaocdn.net/argon/130x130_85_c/E6HRx1AqOPY',
    'movie': 'https://search1.kakaocdn.net/argon/130x130_85_c/36hQpoTrVZp',
    'cafe': 'https://search1.kakaocdn.net/argon/130x130_85_c/E6HRx1AqOPY',
  };

  /// 키워드로 장소 검색
  Future<List<PlaceModel>> searchPlaces({
    required String keyword,
    required double x, // 경도
    required double y, // 위도
    int radius = ApiConstants.searchRadius,
    int size = 15,
    PlaceCategory? category,
  }) async {
    try {
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/keyword.json',
        queryParameters: {
          'query': keyword,
          'x': x,
          'y': y,
          'radius': radius,
          'size': size,
        },
        options: Options(
          headers: {
            'Authorization': 'KakaoAK ${ApiConstants.kakaoApiKey}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final documents = data['documents'] as List<dynamic>? ?? [];

        // 청소년 친화적 필터링
        final filteredPlaces = documents
            .where((place) => _isYouthFriendly(place as Map<String, dynamic>))
            .toList();

        // PlaceModel로 변환 (카테고리별 기본 썸네일 사용)
        return filteredPlaces.map<PlaceModel>((place) {
          final placeMap = place as Map<String, dynamic>;

          // 카테고리별 기본 썸네일 사용 (CORS 이슈로 이미지 검색 비활성화)
          final defaultThumbnail = category != null
              ? defaultThumbnails[category.code]
              : null;

          return PlaceModel(
            id: placeMap['id'] as String,
            name: placeMap['place_name'] as String,
            category: category ?? PlaceCategory.cafe,
            location: _extractLocation(placeMap['address_name'] as String? ?? ''),
            address: placeMap['road_address_name'] as String? ??
                placeMap['address_name'] as String? ??
                '',
            phone: placeMap['phone'] as String? ?? '',
            distance: _formatDistance(placeMap['distance'] as String? ?? '0'),
            thumbnail: defaultThumbnail,
            url: placeMap['place_url'] as String,
            x: double.parse(placeMap['x'] as String),
            y: double.parse(placeMap['y'] as String),
            categoryDetail: placeMap['category_name'] as String?,
          );
        }).toList();
      }

      return [];
    } catch (e) {
      throw Exception('장소 검색 실패: $e');
    }
  }

  /// 카테고리별 장소 검색
  Future<List<PlaceModel>> searchByCategory({
    required PlaceCategory category,
    required double x,
    required double y,
    int radius = ApiConstants.searchRadius,
    int size = 10,
  }) async {
    final keyword = categoryKeywords[category.code] ?? '카페';

    final places = await searchPlaces(
      keyword: keyword,
      x: x,
      y: y,
      radius: radius,
      size: size,
      category: category,
    );

    return places.take(size).toList();
  }

  /// 모든 카테고리 장소 가져오기
  Future<List<PlaceModel>> getAllPlaces({
    required double x,
    required double y,
    int radius = ApiConstants.searchRadius,
    int sizePerCategory = 5,
  }) async {
    final allPlaces = <PlaceModel>[];

    for (final category in PlaceCategory.values) {
      try {
        final places = await searchByCategory(
          category: category,
          x: x,
          y: y,
          radius: radius,
          size: sizePerCategory,
        );
        allPlaces.addAll(places);
      } catch (e) {
        // 개별 카테고리 검색 실패 시 계속 진행
        continue;
      }
    }

    return allPlaces;
  }
}
