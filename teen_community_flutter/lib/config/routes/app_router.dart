import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

/// 앱 라우터 설정 (GoRouter)
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      // 홈
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const PlaceholderScreen(title: '홈'),
      ),

      // 탐색
      GoRoute(
        path: RouteNames.explore,
        builder: (context, state) => const PlaceholderScreen(title: '탐색'),
      ),

      // 추천
      GoRoute(
        path: RouteNames.recommend,
        builder: (context, state) => const PlaceholderScreen(title: '추천'),
      ),

      // 모임
      GoRoute(
        path: RouteNames.meeting,
        builder: (context, state) => const PlaceholderScreen(title: '모임'),
      ),
      GoRoute(
        path: RouteNames.meetingCreate,
        builder: (context, state) => const PlaceholderScreen(title: '모임 만들기'),
      ),

      // 커뮤니티
      GoRoute(
        path: RouteNames.community,
        builder: (context, state) => const PlaceholderScreen(title: '소식'),
      ),
      GoRoute(
        path: RouteNames.communityWrite,
        builder: (context, state) => const PlaceholderScreen(title: '글쓰기'),
      ),
      GoRoute(
        path: RouteNames.postDetail,
        builder: (context, state) {
          final postId = state.pathParameters['postId'] ?? '';
          return PlaceholderScreen(title: '게시글 상세 ($postId)');
        },
      ),

      // 프로필
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const PlaceholderScreen(title: '프로필'),
      ),
      GoRoute(
        path: RouteNames.bookmarked,
        builder: (context, state) => const PlaceholderScreen(title: '북마크'),
      ),
      GoRoute(
        path: RouteNames.friends,
        builder: (context, state) => const PlaceholderScreen(title: '친구'),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const PlaceholderScreen(title: '설정'),
      ),

      // 인증
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const PlaceholderScreen(title: '로그인'),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => const PlaceholderScreen(title: '회원가입'),
      ),

      // 장소 상세
      GoRoute(
        path: RouteNames.placeDetail,
        builder: (context, state) => const PlaceholderScreen(title: '장소 상세'),
      ),
    ],
    errorBuilder: (context, state) => const PlaceholderScreen(title: '404 - 페이지를 찾을 수 없습니다'),
  );
}

/// 임시 플레이스홀더 화면 (실제 화면 구현 전까지 사용)
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 80,
              color: Color(0xFFF4A460),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '준비 중입니다...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
