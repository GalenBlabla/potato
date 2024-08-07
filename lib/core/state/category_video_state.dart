// lib/core/state/category_video_state.dart

import 'package:flutter/material.dart';
import 'package:potato/data/api/video_api_service.dart';

class CategoryVideoState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();
  final Map<String, List<Map<String, dynamic>>> _categoryVideosCache = {}; // 缓存
  bool _isLoadingCategory = false;
  int _selectedYear = 0; // 默认选择2023年
  int _currentPage = 1; // 当前页码
  bool _hasMoreVideos = true; // 是否有更多视频

  List<Map<String, dynamic>> _categoryVideos = [];

  List<Map<String, dynamic>> get categoryVideos => _categoryVideos;
  bool get isLoadingCategory => _isLoadingCategory;
  int get selectedYear => _selectedYear;
  int get currentPage => _currentPage;
  bool get hasMoreVideos => _hasMoreVideos;

  void setSelectedYear(int year) {
    _selectedYear = year;
    _currentPage = 1; // 重置页码
    _hasMoreVideos = true; // 重置更多视频标志
    notifyListeners();
  }

  /// 获取指定分类的视频
  Future<void> fetchCategoryVideos(String categoryUrl,
      {bool forceRefresh = false}) async {
    if (_isLoadingCategory) return; // 防止重复请求
    _isLoadingCategory = true;
    notifyListeners();

    // 生成特定年份和页码的 URL
    final yearSuffix = _selectedYear == 0 ? '' : '$_selectedYear';
    final pageSuffix = _currentPage == 1 ? '' : '$_currentPage';
    final fullUrl = '${categoryUrl}--------${pageSuffix}---${yearSuffix}.html';

    print("Fetching category videos for $fullUrl");

    try {
      final videos = await _videoApiService.getCategoryVideos(fullUrl,
          forceRefresh: forceRefresh);
      if (_currentPage == 1) {
        _categoryVideos = videos;
      } else {
        _categoryVideos.addAll(videos);
      }
      _categoryVideosCache[fullUrl] = videos;
      _hasMoreVideos = videos.isNotEmpty;
      print("Fetched videos: ${videos.length} for year $_selectedYear");
    } catch (error) {
      if (_currentPage == 1) {
        _categoryVideos = [];
      }
      print("Error fetching videos: $error");
    } finally {
      _isLoadingCategory = false;
      notifyListeners();
    }
  }

  /// 加载更多视频
  Future<void> loadMoreVideos(String categoryUrl) async {
    if (_isLoadingCategory || !_hasMoreVideos) return;
    _currentPage++;
    await fetchCategoryVideos(categoryUrl);
  }

  /// 加载上一页视频
  Future<void> loadPreviousVideos(String categoryUrl) async {
    if (_isLoadingCategory || _currentPage <= 1) return;
    _currentPage--;
    await fetchCategoryVideos(categoryUrl);
  }

  /// 根据索引获取分类视频
  List<Map<String, dynamic>> getCategoryVideosByIndex(int index) {
    final categoryUrl = _getCategoryUrlByIndex(index);
    final yearSuffix = _selectedYear == 0 ? '' : '$_selectedYear';
    final pageSuffix = _currentPage == 1 ? '' : '$_currentPage';
    final fullUrl = '$categoryUrl--------$pageSuffix---$yearSuffix.html';
    print('根据索引获取分类视频:$fullUrl');
    return _categoryVideosCache[fullUrl] ?? [];
  }

  /// 根据索引获取分类URL
  String _getCategoryUrlByIndex(int index) {
    const List<String> categoryUrls = [
      '/show/ribendongman',
      '/show/guochandongman',
      '/show/omeidongman',
      '/show/dongmandianying',
    ];
    return categoryUrls[index];
  }
}
