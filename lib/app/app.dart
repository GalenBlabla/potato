import 'package:flutter/material.dart';
import 'package:potato/core/theme/app_theme.dart';
import 'package:potato/core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Anime-Style',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false, // 关闭 debug 横幅
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
    );
  }
}
