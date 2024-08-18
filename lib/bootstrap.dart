// lib/bootstrap.dart
import 'package:flutter/material.dart';
import 'package:potato/core/state/video_play_state.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/state/category_video_state.dart';
import 'core/state/video_detail_state.dart';
import 'core/state/home_page_state.dart';
import 'core/state/search_state.dart';
import 'core/state/announcement_state.dart';


Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryVideoState()),
        ChangeNotifierProvider(create: (_) => VideoDetailState()),
        ChangeNotifierProvider(create: (_) => HomePageState()),
        ChangeNotifierProvider(create: (_) => SearchState()),
        ChangeNotifierProvider(create: (_) => AnnouncementState()),
        ChangeNotifierProvider(create: (_)=> VideoPlayState()),
      ],
      child: const App(),
    ),
  );
}
