import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/route_names.dart';

/// 앱 공통 레이아웃 (헤더 + 하단 네비게이션)
class AppScaffold extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    // 하단 네비게이션 숨김 경로
    final hideNavPaths = [
      RouteNames.login,
      RouteNames.signup,
      RouteNames.placeDetail,
      RouteNames.communityWrite,
      RouteNames.bookmarked,
      RouteNames.friends,
      RouteNames.settings,
    ];

    final shouldHideNav = hideNavPaths.contains(currentPath) ||
        currentPath.startsWith('/community/post/');

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐶 시험끝 오늘은 놀자!'),
        automaticallyImplyLeading: false,
      ),
      body: child,
      bottomNavigationBar: shouldHideNav
          ? null
          : BottomNavigationBar(
              currentIndex: _getCurrentIndex(),
              onTap: (index) => _onItemTapped(context, index),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Text('🏠', style: TextStyle(fontSize: 24)),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Text('🔍', style: TextStyle(fontSize: 24)),
                  label: '탐색',
                ),
                BottomNavigationBarItem(
                  icon: Text('➕', style: TextStyle(fontSize: 24)),
                  label: '모임',
                ),
                BottomNavigationBarItem(
                  icon: Text('💬', style: TextStyle(fontSize: 24)),
                  label: '소식',
                ),
                BottomNavigationBarItem(
                  icon: Text('👤', style: TextStyle(fontSize: 24)),
                  label: 'MY',
                ),
              ],
            ),
    );
  }

  int _getCurrentIndex() {
    if (currentPath == RouteNames.home) return 0;
    if (currentPath.startsWith('/explore')) return 1;
    if (currentPath.startsWith('/meeting')) return 2;
    if (currentPath.startsWith('/community')) return 3;
    if (currentPath.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.explore);
        break;
      case 2:
        context.go(RouteNames.meeting);
        break;
      case 3:
        context.go(RouteNames.community);
        break;
      case 4:
        context.go(RouteNames.profile);
        break;
    }
  }
}
