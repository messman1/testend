/// 앱 라우트 이름 상수
class RouteNames {
  // 홈
  static const String home = '/';

  // 탐색
  static const String explore = '/explore';

  // 추천
  static const String recommend = '/recommend';

  // 모임
  static const String meeting = '/meeting';
  static const String meetingCreate = '/meeting/create';

  // 커뮤니티
  static const String community = '/community';
  static const String communityWrite = '/community/write';
  static const String postDetail = '/community/post/:postId';

  // 프로필
  static const String profile = '/profile';
  static const String bookmarked = '/bookmarked';
  static const String friends = '/friends';
  static const String settings = '/settings';

  // 인증
  static const String login = '/login';
  static const String signup = '/signup';

  // 장소 상세
  static const String placeDetail = '/place';

  /// PostDetail 경로를 생성하는 헬퍼 함수
  static String postDetailPath(String postId) {
    return '/community/post/$postId';
  }
}
