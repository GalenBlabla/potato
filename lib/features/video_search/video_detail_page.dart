// lib/features/video_search/video_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/services.dart'; // 新增的导入
import 'package:Potato/core/state/video_state.dart';

class VideoDetailPage extends StatefulWidget {
  final String link;
  const VideoDetailPage({required this.link, super.key});

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    super.initState();

    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black, // 设置状态栏背景色为黑色
        statusBarIconBrightness: Brightness.light, // 状态栏图标颜色为白色
      ),
    );

    final videoState = Provider.of<VideoState>(context, listen: false);
    videoState.fetchVideoInfo(widget.link).then((_) {
      // 自动播放第一集
      videoState.playEpisodeAtIndex(0);
    });
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    // 重置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoState = Provider.of<VideoState>(context);
    final videoInfo = videoState.videoInfo;

    return Scaffold(
      body: SafeArea(
        child: videoState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : videoState.hasError
                ? const Center(child: Text('Error loading video information'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: videoState.betterPlayerController != null
                            ? BetterPlayer(controller: videoState.betterPlayerController!)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: videoInfo != null
                            ? Text(
                                videoInfo['title'],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 16),
                      if (videoInfo != null && videoInfo['episodes'] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Episodes:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                '正在播放${videoState.currentEpisodeIndex + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (videoInfo != null && videoInfo['episodes'] != null)
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            children: videoInfo['episodes'].entries.map<Widget>((entry) {
                              final lineName = entry.key;
                              final episodeList = entry.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lineName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ...episodeList.map<Widget>((episode) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      elevation: 5.0,
                                      child: ListTile(
                                        title: Text(episode['name'] ?? ''),
                                        trailing: const Icon(Icons.play_circle_fill, color: Colors.deepPurple),
                                        onTap: () {
                                          videoState.playEpisode(episode['url']);
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
