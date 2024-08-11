// lib/core/state/search_state.dart
import 'package:flutter/material.dart';
import 'package:potato/data/api/video_api_service.dart';

class SearchState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isSearching = false;

  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isSearching => _isSearching;

  /// 搜索视频
  Future<void> searchVideos(
    String query,
  ) async {
    _isLoading = true;
    _hasError = false;
    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _videoApiService.searchVideos(query);
    } catch (error) {
      _hasError = true;
      _searchResults = [];
    } finally {
      _isLoading = false;
      _isSearching = false;
      notifyListeners();
    }
  }

  /// 清空搜索结果
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
