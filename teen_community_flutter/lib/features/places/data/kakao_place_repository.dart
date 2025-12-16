import 'package:dio/dio.dart';
import '../../../config/constants/api_constants.dart';
import '../domain/models/place_model.dart';

/// 정렬 유형
enum PlaceSortType {
  distance,
  rating,
}

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
  static const defaultThumbnails = {
    'karaoke': 'https://search1.kakaocdn.net/argon/130x130_85_c/Kp2KXLzRwOd',
    'escape': 'https://search1.kakaocdn.net/argon/130x130_85_c/IxxsexaSwPv',
    'board': 'https://search1.kakaocdn.net/argon/130x130_85_c/E6HRx1AqOPY',
    'movie': 'https://search1.kakaocdn.net/argon/130x130_85_c/36hQpoTrVZp',
    'cafe': 'https://search1.kakaocdn.net/argon/130x130_85_c/E6HRx1AqOPY',
  };

  /// 이미지 캐시
  final Map<String, String?> _imageCache = {};

  /// 카카오 이미지 검색 API로 장소 썸네일 가져오기
  Future<String?> _searchPlaceImage(String placeName) async {
    // 캐시 확인
    if (_imageCache.containsKey(placeName)) {
      return _imageCache[placeName];
    }

    try {
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/search/image',
        queryParameters: {
          'query': placeName,
          'size': 1,
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

        if (documents.isNotEmpty) {
          // image_url (원본 크기) 사용
          final imageUrl = documents[0]['image_url'] as String?;
          _imageCache[placeName] = imageUrl;
          return imageUrl;
        }
      }

      _imageCache[placeName] = null;
      return null;
    } catch (e) {
      _imageCache[placeName] = null;
      return null;
    }
  }

  /// 키워드로 장소 검색
  Future<List<PlaceModel>> searchPlaces({
    required String keyword,
    required double x, // 경도
    required double y, // 위도
    int radius = ApiConstants.searchRadius,
    int size = 15,
    PlaceCategory? category,
    PlaceSortType sortType = PlaceSortType.rating,
  }) async {
    try {
      // 카카오 API 정렬 기준: distance(거리순) 또는 accuracy(정확도순)
      // 평점순(rating)은 API에서 지원하지 않으므로 accuracy로 받아와서 로컬 정렬
      final apiSort = sortType == PlaceSortType.distance ? 'distance' : 'accuracy';

      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/keyword.json',
        queryParameters: {
          'query': keyword,
          'x': x,
          'y': y,
          'radius': radius,
          'size': size,
          'sort': apiSort,
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

        // PlaceModel로 변환 (썸네일 포함)
        final places = <PlaceModel>[];

        for (final place in filteredPlaces) {
          final placeMap = place as Map<String, dynamic>;
          final placeName = placeMap['place_name'] as String;

          // 카카오 이미지 검색 API로 썸네일 가져오기
          final thumbnail = await _searchPlaceImage(placeName);

          // 기본 썸네일 fallback
          final defaultThumbnail = category != null
              ? defaultThumbnails[category.code]
              : null;

          // 랜덤 평점 및 리뷰 수 생성 (API 미지원으로 인한 Mocking)
          // ID를 시드로 사용하여 동일 장소는 항상 동일한 점수가 나오도록 함
          final idHash = placeMap['id'].hashCode;
          // 3.5 ~ 5.0 사이 평점
          final mockRating = 3.5 + (idHash % 16) / 10.0;
          // 10 ~ 500 사이 리뷰 수
          final mockReviewCount = 10 + (idHash % 491);

          places.add(PlaceModel(
            id: placeMap['id'] as String,
            name: placeName,
            category: category ?? PlaceCategory.cafe,
            location: _extractLocation(placeMap['address_name'] as String? ?? ''),
            address: placeMap['road_address_name'] as String? ??
                placeMap['address_name'] as String? ??
                '',
            phone: placeMap['phone'] as String? ?? '',
            distance: _formatDistance(placeMap['distance'] as String? ?? '0'),
            thumbnail: thumbnail ?? defaultThumbnail,
            url: placeMap['place_url'] as String,
            x: double.parse(placeMap['x'] as String),
            y: double.parse(placeMap['y'] as String),
            categoryDetail: placeMap['category_name'] as String?,
            rating: double.parse(mockRating.toStringAsFixed(1)),
            reviewCount: mockReviewCount,
          ));
        }

        // 로컬 정렬
        if (sortType == PlaceSortType.rating) {
          // 평점순 정렬 (높은 순)
          places.sort((a, b) => b.rating.compareTo(a.rating));
        }
        // distance는 API가 이미 정렬해서 줌

        return places;
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
    PlaceSortType sortType = PlaceSortType.rating,
  }) async {
    final keyword = categoryKeywords[category.code] ?? '카페';

    final places = await searchPlaces(
      keyword: keyword,
      x: x,
      y: y,
      radius: radius,
      size: size,
      category: category,
      sortType: sortType,
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



    // 평점순 정렬 (높은 순)
    allPlaces.sort((a, b) => b.rating.compareTo(a.rating));

    return allPlaces;
  }
}
