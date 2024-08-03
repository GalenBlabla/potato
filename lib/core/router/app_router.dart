import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Potato/features/homepage/homepage.dart';
import 'package:Potato/features/video_search/video_search_page.dart';
import 'package:Potato/features/video_search/video_detail_page.dart';
import 'package:Potato/navigation/main_navigation.dart';


final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'Home',
        pageBuilder: (context, state) => const MaterialPage(
          child: MainNavigation(),
        ),
        routes: [
          GoRoute(
            path: 'video_detail/:link',
            name: 'VideoDetail',
            builder: (context, state) {
              final link = state.pathParameters['link']!; // 使用 pathParameters
              return VideoDetailPage(link: link);
            },
          ),
        ],
      ),
    ],
  );
}
