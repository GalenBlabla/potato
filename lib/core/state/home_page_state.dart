// lib/core/state/home_page_state.dart
import 'package:flutter/material.dart';
import 'package:potato/data/api/video_api_service.dart';

class HomePageState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();
  List<Map<String, dynamic>> _carouselVideos = [];
  List<Map<String, dynamic>> _recommendedVideos = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<Map<String, dynamic>> get carouselVideos => _carouselVideos;
  List<Map<String, dynamic>> get recommendedVideos => _recommendedVideos;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  /// 获取主页数据（轮播视频和推荐视频）
  Future<void> fetchHomePageData() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _carouselVideos =
          await _videoApiService.getCarouselVideos();
      _recommendedVideos = await _videoApiService.getRecommendedVideos();
    } catch (error) {
      _hasError = true;
      _carouselVideos = [];
      _recommendedVideos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
