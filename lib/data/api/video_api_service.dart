// data/api/video_api_service.dart
import 'cache_manager.dart'; // 导入缓存管理器
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoApiService {
  final String baseUrl = "http://192.168.28.79:8001";
  final CacheManager _cacheManager = CacheManager();

  // 搜索视频
  Future<List<Map<String, dynamic>>> searchVideos(String query) async {
    final cacheKey = 'search_$query';
    final cachedData = _cacheManager.get(cacheKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(cachedData);
    }

    final url = Uri.parse('$baseUrl/api/search/search_kw/$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = utf8.decode(response.bodyBytes);
      final result = List<Map<String, dynamic>>.from(json.decode(data));
      _cacheManager.set(cacheKey, result); // 缓存数据
      return result;
    } else {
      throw Exception('Failed to load data');
    }
  }

  // 获取搜索结果
  Future<Map<String, dynamic>> fetchVideoInfo(String link) async {
    final cacheKey = 'video_info_$link';
    final cachedData = _cacheManager.get(cacheKey);

    if (cachedData != null) {
      return Map<String, dynamic>.from(cachedData);
    }

    final url = Uri.parse('$baseUrl/api/video_info/detail_page?link=$link');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      _cacheManager.set(cacheKey, data); // 缓存数据
      return data;
    } else {
      throw Exception('Failed to load video info');
    }
  }
  // 获取视频详细地址
  Future<String> getDecryptedUrl(String videoSource) async {
    // 对 videoSource 进行编码
    final encodedVideoSource = Uri.encodeComponent(videoSource);
    final url = Uri.parse('$baseUrl/api/episodes/get_decrypted_url/?video_source=$encodedVideoSource');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['decrypted_url'];
    } else {
      throw Exception('Failed to decrypt URL');
    }
  }
  // 获取视频播放地址
  Future<String> getEpisodeInfo(String episodeLink) async {
    final cacheKey = 'episode_info_$episodeLink';
    final cachedData = _cacheManager.get(cacheKey);

    if (cachedData != null) {
      return cachedData as String;
    }

    final url = Uri.parse('$baseUrl/api/episodes/episode_info/?episode_link=$episodeLink');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final videoSource = data['video_source'];
      _cacheManager.set(cacheKey, videoSource); // 缓存数据
      return videoSource;
    } else {
      throw Exception('Failed to load episode info');
    }
  }

  // 获取主页轮播视频
  Future<List<Map<String, dynamic>>> getCarouselVideos() async {
    final cacheKey = 'carousel_videos';
    final cachedData = _cacheManager.get(cacheKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(cachedData);
    }

    final url = Uri.parse('$baseUrl/api/home/carousel_videos');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = utf8.decode(response.bodyBytes);
      final result = List<Map<String, dynamic>>.from(json.decode(data));
      _cacheManager.set(cacheKey, result); // 缓存数据
      return result;
    } else {
      throw Exception('Failed to load carousel videos');
    }
  }

  // 获取主页推荐视频
  Future<List<Map<String, dynamic>>> getRecommendedVideos() async {
    final cacheKey = 'recommended_videos';
    final cachedData = _cacheManager.get(cacheKey);

    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(cachedData);
    }

    final url = Uri.parse('$baseUrl/api/home/recommended_videos');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = utf8.decode(response.bodyBytes);
      final result = List<Map<String, dynamic>>.from(json.decode(data));
      _cacheManager.set(cacheKey, result); // 缓存数据
      return result;
    } else {
      throw Exception('Failed to load recommended videos');
    }
  }
}
