import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
// import 'dart:typed_data';
import 'cache_manager.dart'; // 导入缓存管理器

class VideoApiService {
  final String baseUrl = "http://192.168.28.79:8001";
  final CacheManager _cacheManager = CacheManager();
  final String targetUrl = "https://www.dmla7.com";

  Future<T> fetchData<T>(
    String endpoint, {
    required String cacheKey,
    required String targetUrlPath,
    required T Function(dynamic data) parseData,
    bool isFullUrl = false,
    bool forceRefresh = false, // 新增参数，默认为 false
  }) async {
    // 如果不强制刷新且缓存存在，直接返回缓存数据
    if (!forceRefresh) {
      final cachedData = _cacheManager.get(cacheKey);
      if (cachedData != null) {
        return parseData(cachedData);
      }
    }

    // 判断是否为完整链接
    final url = isFullUrl
        ? Uri.parse(targetUrlPath)
        : Uri.parse('$targetUrl$targetUrlPath');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final htmlContent = response.body;
      final compressedContent = gzip.encode(utf8.encode(htmlContent));
      final encodedContent = base64.encode(compressedContent);

      final apiUrl = Uri.parse('$baseUrl$endpoint');
      final apiResponse = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'html_content': encodedContent}),
      );

      if (apiResponse.statusCode == 200) {
        final data = json.decode(utf8.decode(apiResponse.bodyBytes));
        _cacheManager.set(cacheKey, data); // 缓存数据
        return parseData(data);
      } else {
        throw Exception('Failed to load data from $endpoint');
      }
    } else {
      throw Exception('Failed to fetch HTML content from $targetUrlPath');
    }
  }

  // 搜索视频
  Future<List<Map<String, dynamic>>> searchVideos(String query,
      {bool forceRefresh = false}) async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/search/search_kw',
      cacheKey: 'search_$query',
      targetUrlPath: '/search/-------------.html?wd=$query',
      parseData: (data) => List<Map<String, dynamic>>.from(data),
      forceRefresh: forceRefresh,
    );
  }

  // 获取搜索结果
  Future<Map<String, dynamic>> fetchVideoInfo(String link,
      {bool forceRefresh = false}) async {
    return fetchData<Map<String, dynamic>>(
      '/api/video_info/detail_page',
      cacheKey: 'video_info_$link',
      targetUrlPath: link,
      parseData: (data) => Map<String, dynamic>.from(data),
      forceRefresh: forceRefresh,
    );
  }

  // 获取视频播放地址
  Future<String> getEpisodeInfo(String episodeLink,
      {bool forceRefresh = false}) async {
    return fetchData<String>(
      '/api/episodes/episode_info',
      cacheKey: 'episode_info_$episodeLink',
      targetUrlPath: episodeLink,
      parseData: (data) => data['video_source'] as String,
      forceRefresh: forceRefresh,
    );
  }

  // 获取视频详细地址
  Future<String> getDecryptedUrl(String videoSource,
      {bool forceRefresh = false}) async {
    return fetchData<String>(
      '/api/episodes/get_decrypted_url',
      cacheKey: 'decrypted_url_$videoSource',
      targetUrlPath: videoSource, // 直接传递完整的链接
      parseData: (data) => data['decrypted_url'] as String,
      isFullUrl: true, // 设置为 true，表示 targetUrlPath 是完整的链接
      forceRefresh: forceRefresh,
    );
  }

  // 获取主页轮播视频
  Future<List<Map<String, dynamic>>> getCarouselVideos(
      {bool forceRefresh = false}) async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/home/carousel_videos',
      cacheKey: 'carousel_videos',
      targetUrlPath: '/',
      parseData: (data) => List<Map<String, dynamic>>.from(data),
      forceRefresh: forceRefresh,
    );
  }

  // 获取主页推荐视频
  Future<List<Map<String, dynamic>>> getRecommendedVideos(
      {bool forceRefresh = false}) async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/home/recommended_videos',
      cacheKey: 'recommended_videos',
      targetUrlPath: '/',
      parseData: (data) => List<Map<String, dynamic>>.from(data),
      forceRefresh: forceRefresh,
    );
  }

  // 获取指定分类的所有视频
  Future<List<Map<String, dynamic>>> getCategoryVideos(String categoryUrl,
      {bool forceRefresh = false}) async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/home/get_page_total_videos',
      cacheKey: 'category_videos_$categoryUrl',
      targetUrlPath: categoryUrl,
      parseData: (data) => List<Map<String, dynamic>>.from(data),
      forceRefresh: forceRefresh,
    );
  }

  // 获取总页数量
  Future<int> getTotalPages(String categoryUrl,
      {bool forceRefresh = false}) async {
    return fetchData<int>(
      '/api/home/total_pages',
      cacheKey: 'total_pages_$categoryUrl',
      targetUrlPath: categoryUrl,
      parseData: (data) => data['total_pages'] as int,
      forceRefresh: forceRefresh,
    );
  }

  // 获取年份信息
  Future<List<Map<String, dynamic>>> getYears(String categoryUrl,
      {bool forceRefresh = false}) async {
    return fetchData<List<Map<String, dynamic>>>(
      '/api/home/years',
      cacheKey: 'years_$categoryUrl',
      targetUrlPath: categoryUrl,
      parseData: (data) => List<Map<String, dynamic>>.from(data),
      forceRefresh: forceRefresh,
    );
  }

  // 获取公告信息
  Future<List<Map<String, dynamic>>> fetchAnnouncements(
      {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedData = _cacheManager.get('announcements');
      if (cachedData != null) {
        return List<Map<String, dynamic>>.from(cachedData);
      }
    }

    final url = Uri.parse('$baseUrl/api/home/announcements');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = utf8.decode(response.bodyBytes);
      final result = List<Map<String, dynamic>>.from(json.decode(data));
      _cacheManager.set('announcements', result); // 缓存数据
      return result;
    } else {
      throw Exception('Failed to load announcements');
    }
  }
}
