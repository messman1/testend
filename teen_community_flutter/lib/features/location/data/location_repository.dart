import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../config/constants/api_constants.dart';

/// 위치 데이터 모델
class LocationData {
  final double latitude;
  final double longitude;
  final String address; // 예: "역삼동"

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  String toString() =>
      'LocationData(lat: $latitude, lng: $longitude, address: $address)';
}

/// 위치 서비스 리포지토리
class LocationRepository {
  final Dio _dio;

  LocationRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout:
                  const Duration(milliseconds: ApiConstants.connectionTimeout),
              receiveTimeout:
                  const Duration(milliseconds: ApiConstants.receiveTimeout),
            ));

  /// 위치 권한 확인 및 요청
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다. 설정에서 활성화해주세요.');
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
    }

    return true;
  }

  /// 현재 위치 가져오기
  Future<Position> getCurrentPosition() async {
    try {
      await checkAndRequestPermission();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      throw Exception('위치를 가져올 수 없습니다: $e');
    }
  }

  /// 좌표를 주소로 변환 (카카오 API)
  Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/geo/coord2address.json',
        queryParameters: {
          'x': longitude,
          'y': latitude,
        },
        options: Options(
          headers: {
            'Authorization': 'KakaoAK ${ApiConstants.kakaoApiKey}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['documents'] != null && data['documents'].isNotEmpty) {
          final document = data['documents'][0];

          // 도로명 주소가 있으면 도로명, 없으면 지번 주소 사용
          if (document['road_address'] != null) {
            final region3 = document['road_address']['region_3depth_name'] ?? '';
            return region3.isNotEmpty ? region3 : '알 수 없는 위치';
          } else if (document['address'] != null) {
            final region3 = document['address']['region_3depth_name'] ?? '';
            return region3.isNotEmpty ? region3 : '알 수 없는 위치';
          }
        }
      }

      return '알 수 없는 위치';
    } catch (e) {
      // 주소 변환 실패 시 기본값 반환
      return '위치 불러오기 실패';
    }
  }

  /// 현재 위치와 주소를 함께 가져오기
  Future<LocationData> getCurrentLocationWithAddress() async {
    try {
      // 1. GPS 좌표 가져오기
      final position = await getCurrentPosition();

      // 2. 좌표를 주소로 변환
      final address = await getAddressFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 기본 위치 반환 (서울 시청)
  LocationData getDefaultLocation() {
    return const LocationData(
      latitude: ApiConstants.defaultLatitude,
      longitude: ApiConstants.defaultLongitude,
      address: '서울',
    );
  }
}
