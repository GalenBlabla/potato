import 'package:flutter/material.dart';
import 'package:potato/data/api/video_api_service.dart';

class CategoryVideoState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();
  final Map<int, Map<int, List<Map<String, dynamic>>>> _categoryVideosCache =
      {}; // 多层缓存
  bool _isLoadingCategory = false;
  bool _hasMoreVideos = true; // 是否有更多视频
  int _currentPage = 1; // 当前页码
  int _selectedYear = 0; // 默认选择全部年份（0 表示全部）

  // 获取当前的年份
  int get selectedYear => _selectedYear;
  int get currentPage => _currentPage;
  bool get isLoadingCategory => _isLoadingCategory;
  bool get hasMoreVideos => _hasMoreVideos;

  // 设置选中的年份
  void setSelectedYear(int year) {
    _selectedYear = year;
    _currentPage = 1; // 重置页码
    _hasMoreVideos = true; // 重置更多视频标志
    notifyListeners();
  }

  // 获取指定 Tab 和年份的缓存视频数据
  List<Map<String, dynamic>> getCategoryVideos(int tabIndex, int year) {
    return _categoryVideosCache[tabIndex]?[year] ?? [];
  }

  // 获取指定 Tab 和年份的视频
  Future<void> fetchCategoryVideos(int tabIndex, String categoryUrl) async {
    if (_isLoadingCategory) return; // 防止重复请求
    _isLoadingCategory = true;
    notifyListeners();

    // 生成特定年份和页码的 URL
    final yearSuffix = _selectedYear == 0 ? '' : '$_selectedYear';
    final pageSuffix = _currentPage == 1 ? '' : '$_currentPage';
    final fullUrl = '${categoryUrl}--------${pageSuffix}---${yearSuffix}.html';

    try {
      final videos = await _videoApiService.getCategoryVideos(fullUrl);

      // 缓存数据到对应的 Tab 和年份中
      _categoryVideosCache.putIfAbsent(tabIndex, () => {});
      _categoryVideosCache[tabIndex]?.putIfAbsent(_selectedYear, () => []);
      if (_currentPage == 1) {
        _categoryVideosCache[tabIndex]?[_selectedYear] = videos;
      } else {
        _categoryVideosCache[tabIndex]?[_selectedYear]?.addAll(videos);
      }

      _hasMoreVideos = videos.isNotEmpty;
    } catch (error) {
      if (_currentPage == 1) {
        _categoryVideosCache[tabIndex]?[_selectedYear] = [];
      }
    } finally {
      _isLoadingCategory = false;
      notifyListeners();
    }
  }

  // 加载更多视频
  Future<void> loadMoreVideos(int tabIndex, String categoryUrl) async {
    if (_isLoadingCategory || !_hasMoreVideos) return;
    _currentPage++;
    await fetchCategoryVideos(tabIndex, categoryUrl);
  }

  // 根据索引获取分类 URL
  String getCategoryUrlByIndex(int index) {
    const List<String> categoryUrls = [
      '/show/ribendongman',
      '/show/guochandongman',
      '/show/omeidongman',
      '/show/dongmandianying',
    ];
    return categoryUrls[index];
  }
}
