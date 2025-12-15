import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';

/// 앱의 루트 위젯
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '시험끝 오늘은 놀자!',
      debugShowCheckedModeBanner: false,

      // 테마 설정 (Material 3 + 강아지 컨셉)
      theme: AppTheme.lightTheme,

      // 라우팅 설정 (GoRouter)
      routerConfig: AppRouter.router,
    );
  }
}
