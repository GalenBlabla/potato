import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:potato/core/state/announcement_state.dart';
import 'dart:async';

class NonePage extends StatefulWidget {
  const NonePage({super.key});

  @override
  _NonePageState createState() => _NonePageState();
}

class _NonePageState extends State<NonePage> {
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          // Update UI after animation
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAnnouncements();
    });
  }

  Future<void> _fetchAnnouncements() async {
    final announcementState =
        Provider.of<AnnouncementState>(context, listen: false);
    if (announcementState.announcements.isEmpty) {
      await announcementState.fetchAnnouncements();
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('公告栏'),
      ),
      body: Consumer<AnnouncementState>(
        builder: (context, announcementState, child) {
          if (announcementState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (announcementState.hasError) {
            return const Center(child: Text('加载公告信息失败'));
          } else if (announcementState.announcements.isEmpty) {
            return const Center(child: Text('暂无公告'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: announcementState.announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcementState.announcements[index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(
                      announcement['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          announcement['content'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          announcement['date'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showAnnouncementDialog(
                        context,
                        announcement['title'],
                        announcement['content'],
                        announcement['date'],
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showAnnouncementDialog(
      BuildContext context, String title, String content, String date) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  date,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
