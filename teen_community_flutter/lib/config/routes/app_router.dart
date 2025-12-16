import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/profile/presentation/pages/bookmarked_page.dart';
import '../../features/profile/presentation/pages/friends_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/recommend/presentation/pages/recommend_page.dart';
import '../../features/meeting/presentation/pages/meeting_page.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/community/presentation/pages/write_post_page.dart';
import '../../features/community/presentation/pages/post_detail_page.dart';
import '../../features/places/presentation/pages/place_detail_page.dart';
import '../../features/places/domain/models/place_model.dart';
import '../../features/common/presentation/widgets/app_scaffold.dart';

/// 앱 라우터 설정 (GoRouter)
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      // 메인 레이아웃 (하단 네비게이션 포함)
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          // 홈
          GoRoute(
            name: RouteNames.home,
            path: RouteNames.home,
            builder: (context, state) => const HomePage(),
          ),

          // 탐색
          GoRoute(
            name: RouteNames.explore,
            path: RouteNames.explore,
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return ExplorePage(initialCategory: category);
            },
          ),

          // 추천
          GoRoute(
            name: RouteNames.recommend,
            path: RouteNames.recommend,
            builder: (context, state) => const RecommendPage(),
          ),

          // 모임
          GoRoute(
            name: RouteNames.meeting,
            path: RouteNames.meeting,
            builder: (context, state) => const MeetingPage(),
          ),
          GoRoute(
            name: RouteNames.meetingCreate,
            path: RouteNames.meetingCreate,
            builder: (context, state) => const MeetingPage(),
          ),

          // 커뮤니티
          GoRoute(
            name: RouteNames.community,
            path: RouteNames.community,
            builder: (context, state) => const CommunityPage(),
          ),
          GoRoute(
            name: RouteNames.communityWrite,
            path: RouteNames.communityWrite,
            builder: (context, state) => const WritePostPage(),
          ),
          GoRoute(
            name: RouteNames.postDetail,
            path: RouteNames.postDetail,
            builder: (context, state) {
              final postId = state.pathParameters['postId'] ?? '';
              return PostDetailPage(postId: postId);
            },
          ),

          // 프로필
          GoRoute(
            name: RouteNames.profile,
            path: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            name: RouteNames.bookmarked,
            path: RouteNames.bookmarked,
            builder: (context, state) => const BookmarkedPage(),
          ),
          GoRoute(
            name: RouteNames.friends,
            path: RouteNames.friends,
            builder: (context, state) => const FriendsPage(),
          ),
          GoRoute(
            name: RouteNames.settings,
            path: RouteNames.settings,
            builder: (context, state) => const SettingsPage(),
          ),

          // 장소 상세
          GoRoute(
            name: RouteNames.placeDetail,
            path: RouteNames.placeDetail,
            builder: (context, state) {
              final url = state.uri.queryParameters['url'] ?? '';
              final name = state.uri.queryParameters['name'] ?? '장소 상세';
              final place = state.extra as PlaceModel?;

              if (url.isEmpty) {
                return const PlaceholderScreen(title: '잘못된 접근입니다');
              }

              return PlaceDetailPage(url: url, name: name, place: place);
            },
          ),
        ],
      ),

      // 인증 (ShellRoute 밖 - 하단 네비게이션 없음)
      GoRoute(
        name: RouteNames.login,
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: RouteNames.signup,
        path: RouteNames.signup,
        builder: (context, state) => const SignUpPage(),
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
