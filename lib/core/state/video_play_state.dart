// states/video_play_state.dart
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';

class VideoPlayState extends ChangeNotifier {
  final FijkPlayer _fijkPlayer = FijkPlayer();

  FijkPlayer get fijkPlayer => _fijkPlayer;

  Future<void> setVideoSource(String url, {bool autoPlay = true}) async {
    try {
      await _fijkPlayer.setDataSource(url, autoPlay: autoPlay);
      notifyListeners();
    } catch (e) {
      print('Error setting video source: $e');
    }
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
