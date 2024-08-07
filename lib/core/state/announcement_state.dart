// lib/core/state/announcement_state.dart
import 'package:flutter/material.dart';
import 'package:potato/data/api/video_api_service.dart';

class AnnouncementState extends ChangeNotifier {
  final VideoApiService _videoApiService = VideoApiService();
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<Map<String, dynamic>> get announcements => _announcements;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  /// 获取公告信息
  Future<void> fetchAnnouncements({bool forceRefresh = false}) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _announcements =
          await _videoApiService.fetchAnnouncements(forceRefresh: forceRefresh);
    } catch (error) {
      _hasError = true;
      _announcements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
