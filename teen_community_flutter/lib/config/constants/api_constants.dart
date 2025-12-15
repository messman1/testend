/// API 관련 상수
class ApiConstants {
  // Supabase
  static const String supabaseUrlKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';

  // Kakao
  static const String kakaoApiKey = '6c3d9e2d50c653818b7fbee8dcd1b9f5';
  static const String kakaoSearchUrl = 'https://dapi.kakao.com/v2/local/search';

  // 기본 위치 (서울 시청)
  static const double defaultLatitude = 37.5666805;
  static const double defaultLongitude = 126.9784147;

  // 검색 반경 (2km)
  static const int searchRadius = 2000;

  // 타임아웃
  static const int connectionTimeout = 30000; // 30초
  static const int receiveTimeout = 30000; // 30초
}
