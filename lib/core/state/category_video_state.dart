import 'package:flutter/material.dart';
import 'package:potato/data/api/video_api_service.dart';

class CategoryVideoState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();
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
    _categoryVideos.clear(); // 清空当前视频列表
    print("Year set to: $_selectedYear, clearing videos and resetting page");
    notifyListeners();
  }

  /// 获取指定分类的视频
  Future<void> fetchCategoryVideos(
    String categoryUrl,
  ) async {
    if (_isLoadingCategory) return; // 防止重复请求
    _isLoadingCategory = true;
    print("Loading videos for URL: $categoryUrl, page: $_currentPage");
    notifyListeners();

    // 生成特定年份和页码的 URL
    final yearSuffix = _selectedYear == 0 ? '' : '$_selectedYear';
    final pageSuffix = _currentPage == 1 ? '' : '$_currentPage';
    final fullUrl = '${categoryUrl}--------${pageSuffix}---${yearSuffix}.html';

    print("Fetching category videos for $fullUrl");
    try {
      final videos = await _videoApiService.getCategoryVideos(fullUrl);
      print("Fetched ${videos.length} videos");

      // 追加新数据到当前列表
      if (_currentPage == 1) {
        _categoryVideos = videos;
        print("Setting videos: ${_categoryVideos.length} items");
      } else {
        _categoryVideos.addAll(videos);
        print("Adding more videos: total now ${_categoryVideos.length} items");
      }

      _hasMoreVideos = videos.isNotEmpty; // 检查是否还有更多视频
      print("Has more videos: $_hasMoreVideos");
    } catch (error) {
      if (_currentPage == 1) {
        _categoryVideos = [];
      }
      print("Error fetching videos: $error");
    } finally {
      _isLoadingCategory = false;
      print("Finished loading videos, notify listeners");
      notifyListeners(); // 只在数据有更新时通知监听器
    }
  }

  /// 加载更多视频
  Future<void> loadMoreVideos(String categoryUrl) async {
    if (_isLoadingCategory || !_hasMoreVideos) return;
    _currentPage++;
    print("Loading more videos, new page: $_currentPage");
    await fetchCategoryVideos(categoryUrl);
  }

  /// 加载上一页视频
  Future<void> loadPreviousVideos(String categoryUrl) async {
    if (_isLoadingCategory || _currentPage <= 1) return;
    _currentPage--;
    print("Loading previous page: $_currentPage");
    await fetchCategoryVideos(categoryUrl);
  }

  /// 根据索引获取分类视频
  List<Map<String, dynamic>> getCategoryVideosByIndex(int index) {
    return _categoryVideos; // 直接返回当前视频列表
  }

  /// 根据索引获取分类URL
  String getCategoryUrlByIndex(int index) {
    const List<String> categoryUrls = [
      '/show/ribendongman',
      '/show/guochandongman',
      '/show/omeidongman',
      '/show/dongmandianying',
    ];
    final categoryUrl = categoryUrls[index];
    print("Category URL for index $index: $categoryUrl");
    return categoryUrl;
  }
}
