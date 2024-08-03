// lib/core/state/video_state.dart
import 'package:flutter/material.dart';
import 'package:potato/data/api/video_api_service.dart';

class VideoState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();

  Map<String, dynamic>? _videoInfo;
  List<Map<String, dynamic>> _carouselVideos = [];
  List<Map<String, dynamic>> _recommendedVideos = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isSearching = false;

  Map<String, dynamic>? get videoInfo => _videoInfo;
  List<Map<String, dynamic>> get carouselVideos => _carouselVideos;
  List<Map<String, dynamic>> get recommendedVideos => _recommendedVideos;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isSearching => _isSearching;

  Future<void> fetchHomePageData() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final carouselData = await _videoApiService.getCarouselVideos();
      final recommendedData = await _videoApiService.getRecommendedVideos();
      _carouselVideos = carouselData;
      _recommendedVideos = recommendedData;
    } catch (error) {
      _hasError = true;
      _carouselVideos = [];
      _recommendedVideos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> searchVideos(String query) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _searchResults = await _videoApiService.searchVideos(query);
    } catch (error) {
      _hasError = true;
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void clearVideoInfo() {
    _videoInfo = null;
    notifyListeners();
  }

  void toggleSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }
}
