// lib/core/state/video_state.dart
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:Potato/data/api/video_api_service.dart';

class VideoState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();
  BetterPlayerController? _betterPlayerController;
  Map<String, dynamic>? _videoInfo;
  List<Map<String, dynamic>> _carouselVideos = [];
  List<Map<String, dynamic>> _recommendedVideos = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isSearching = false;
  int _currentEpisodeIndex = 0;
  String? _currentEpisodeUrl;

  Map<String, dynamic>? get videoInfo => _videoInfo;
  List<Map<String, dynamic>> get carouselVideos => _carouselVideos;
  List<Map<String, dynamic>> get recommendedVideos => _recommendedVideos;
  List<Map<String, dynamic>> get searchResults => _searchResults;
  List<Map<String, dynamic>> get announcements => _announcements;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isSearching => _isSearching;
  int get currentEpisodeIndex => _currentEpisodeIndex;
  String? get currentEpisodeUrl => _currentEpisodeUrl;
  BetterPlayerController? get betterPlayerController => _betterPlayerController;

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
  // 获取指定集的详细信息
  Future<String> getEpisodeInfo(String episodeUrl) async {
    // 调用 API 服务获取视频源信息
    return await _videoApiService.getEpisodeInfo(episodeUrl);
  }

  // 解密视频 URL
  Future<String> getDecryptedUrl(String videoSource) async {
    // 调用 API 服务获取解密后的 URL
    return await _videoApiService.getDecryptedUrl(videoSource);
  }
  // 播放指定的集
  Future<void> playEpisode(String episodeUrl) async {
    try {
      final videoSource = await getEpisodeInfo(episodeUrl);
      final decryptedUrl = await getDecryptedUrl(videoSource);

      final betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        decryptedUrl,
      );

      // 释放之前的播放器
      _betterPlayerController?.dispose();

      // 初始化新的播放器控制器
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          aspectRatio: 16 / 9,
          eventListener: (event) {
            if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
              playNextEpisode();
            }
          },
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );

      _currentEpisodeUrl = episodeUrl;
      notifyListeners();
    } catch (e) {
      print('Error: $e');
    }
  }

  // 设置 BetterPlayerController
  void setBetterPlayerController(BetterPlayerController? controller) {
    _betterPlayerController = controller;
    notifyListeners();
  }

  Future<void> playEpisodeAtIndex(int index) async {
    final videoInfo = _videoInfo;
    if (videoInfo != null && videoInfo['episodes'] != null) {
      final episodes = videoInfo['episodes'];
      final entry = episodes.entries.toList()[index];
      final episode = entry.value[0];

      _currentEpisodeIndex = index;
      await playEpisode(episode['url']);
    }
  }

  void playNextEpisode() {
    final videoInfo = _videoInfo;
    if (videoInfo != null && videoInfo['episodes'] != null) {
      final episodes = videoInfo['episodes'];
      final episodesCount = episodes.entries.length;
      if (_currentEpisodeIndex + 1 < episodesCount) {
        _currentEpisodeIndex++;
        playEpisodeAtIndex(_currentEpisodeIndex);
      } else {
        print('No more episodes to play.');
      }
    }
  }
    // 获取公告信息
  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _announcements = await _videoApiService.fetchAnnouncements();
      print(_announcements);
    } catch (error) {
      _hasError = true;
      _announcements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
