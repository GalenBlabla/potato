// lib/bootstrap.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/state/video_state.dart';
import 'data/api/cache_manager.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheManager().init(); // 初始化缓存管理器

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoState()),
      ],
      child: const App(),
    ),
  );
}
