import 'package:flutter/material.dart';
import 'package:potato/data/api/video_api_service.dart';

class VideoDetailState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();
  Map<String, dynamic>? _videoInfo;
  bool _isLoading = false;
  bool _hasError = false;
  int _currentEpisodeIndex = 0;

  Map<String, dynamic>? get videoInfo => _videoInfo;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  int get currentEpisodeIndex => _currentEpisodeIndex;

  /// 获取视频详细信息
  Future<void> fetchVideoInfo(String link) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _videoInfo = await _videoApiService.fetchVideoInfo(link);
    } catch (error) {
      _hasError = true;
      _videoInfo = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取指定集的详细信息
  Future<String> getEpisodeInfo(String episodeUrl) async {
    return await _videoApiService.getEpisodeInfo(episodeUrl);
  }

  /// 解密视频 URL
  Future<String> getDecryptedUrl(String videoSource) async {
    return await _videoApiService.getDecryptedUrl(videoSource);
  }

  /// 设置当前集数索引
  void setCurrentEpisodeIndex(int index) {
    _currentEpisodeIndex = index;
    notifyListeners();
  }
}
