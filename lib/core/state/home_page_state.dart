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

  /// 是否已经加载过数据
  bool _hasLoadedData = false;

  /// 获取主页数据（轮播视频和推荐视频）
  Future<void> fetchHomePageData({bool forceRefresh = false}) async {
    if (_hasLoadedData && !forceRefresh) {
      return; // 如果已经加载过数据且不强制刷新，则直接返回
    }

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _carouselVideos = await _videoApiService.getCarouselVideos();
      _recommendedVideos = await _videoApiService.getRecommendedVideos();
      _hasLoadedData = true; // 设置已加载标志
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
