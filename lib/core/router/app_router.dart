// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:potato/features/homepage/homepage.dart';
import 'package:potato/features/video_search/video_search_page.dart';
import 'package:potato/features/video_search/video_detail_page.dart';
import 'package:potato/navigation/main_navigation.dart';

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
            path: 'video_search',
            name: 'VideoSearch',
            pageBuilder: (context, state) => MaterialPage(
              child:
                  VideoSearchPage(query: state.extra as String), // 传递 query 参数
            ),
          ),
          GoRoute(
            path: 'video_detail:link',
            name: 'VideoDetail',
            builder: (context, state) {
              final link = state.pathParameters['link']!;
              return VideoDetailPage(link: link);
            },
          ),
          GoRoute(
            path: 'search',
            builder: (context, state) {
              final query = state.extra as String;
              return VideoSearchPage(query: query);
            },
          ),
        ],
      ),
    ],
  );
}
