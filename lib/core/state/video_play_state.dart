import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';

class VideoPlayState extends ChangeNotifier {
  final FijkPlayer _fijkPlayer = FijkPlayer();

  FijkPlayer get fijkPlayer => _fijkPlayer;

  /// 设置视频源并自动播放
  Future<void> setVideoSource(String url, {bool autoPlay = true}) async {
    try {
      await _fijkPlayer.setDataSource(url, autoPlay: autoPlay);
      notifyListeners();
    } catch (e) {
      print('Error setting video source: $e');
    }
  }

  /// 播放指定的集
  Future<void> playEpisode(String url) async {
    await setVideoSource(url, autoPlay: true);
  }

  void releasePlayer() {
    _fijkPlayer.release();
    notifyListeners();
  }

  @override
  void dispose() {
    _fijkPlayer.release();
    super.dispose();
  }
}
