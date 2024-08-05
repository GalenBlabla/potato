import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/services.dart';
import 'package:Potato/core/state/video_state.dart';
import 'package:Potato/features/video_search/components/custom_controls.dart';

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
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // 初始化播放器
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final videoState = Provider.of<VideoState>(context, listen: false);
    await videoState.fetchVideoInfo(widget.link);
    // 清空之前的播放器控制器
    videoState.setBetterPlayerController(null);
    _playEpisodeAtIndex(0); // 自动播放第一集
  }

  Future<void> _playEpisodeAtIndex(int index) async {
    final videoState = Provider.of<VideoState>(context, listen: false);
    if (videoState.videoInfo == null || videoState.videoInfo!['episodes'] == null) return;

    final episodes = videoState.videoInfo!['episodes'];
    if (index >= episodes.entries.length) return;

    final entry = episodes.entries.toList()[index];
    final episode = entry.value[0];
    final url = episode['url'];

    _playEpisode(url);
  }

  Future<void> _playEpisode(String url) async {
    final videoState = Provider.of<VideoState>(context, listen: false);

    // 释放之前的播放器
    _betterPlayerController?.pause();
    _betterPlayerController?.dispose();

    // 播放新视频
    final videoSource = await videoState.getEpisodeInfo(url);
    final decryptedUrl = await videoState.getDecryptedUrl(videoSource);
    final betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      decryptedUrl,
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        aspectRatio: 16 / 9,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControlsOnInitialize: false, // 初始化时不显示控件
          customControlsBuilder: (controller, onControlsVisibilityChanged) {
            return CustomControls(controller: controller); // 使用自定义控件
          },
        ),
        eventListener: (event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
            _playNextEpisode();
          }
        },
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );




    // 设置播放器控制器到 VideoState
    videoState.setBetterPlayerController(_betterPlayerController);
  }

  void _playNextEpisode() {
    final videoState = Provider.of<VideoState>(context, listen: false);
    if (videoState.videoInfo == null || videoState.videoInfo!['episodes'] == null) return;

    final episodes = videoState.videoInfo!['episodes'];
    if (videoState.currentEpisodeIndex + 1 >= episodes.entries.length) return;

    final nextIndex = videoState.currentEpisodeIndex + 1;
    _playEpisodeAtIndex(nextIndex);
  }

  @override
  void dispose() {
    // 释放播放器资源
    _betterPlayerController?.pause();
    _betterPlayerController?.dispose();

    // 清空播放器控制器
    final videoState = Provider.of<VideoState>(context, listen: false);
    videoState.setBetterPlayerController(null);

    // 重置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.dispose();
  }

  // 处理双击事件
  void _onDoubleTap(TapDownDetails details, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.localPosition.dx;
    final isFullScreen = _betterPlayerController?.isFullScreen ?? false;

    if (_betterPlayerController == null) return;

    final currentPosition = _betterPlayerController!.videoPlayerController!.value.position;
    final videoLength = _betterPlayerController!.videoPlayerController!.value.duration ?? Duration.zero;

    final double thirdOfScreen = isFullScreen ? screenWidth / 3 : screenWidth / 2;

    if (tapPosition < thirdOfScreen) {
      final rewindPosition = currentPosition - Duration(seconds: 10);
      _betterPlayerController!.seekTo(rewindPosition > Duration.zero ? rewindPosition : Duration.zero);
    } else if (tapPosition > (isFullScreen ? 2 * thirdOfScreen : thirdOfScreen)) {
      final forwardPosition = currentPosition + Duration(seconds: 10);
      _betterPlayerController!.seekTo(forwardPosition < videoLength ? forwardPosition : videoLength);
    } else {
      if (_betterPlayerController!.isPlaying() ?? false) {
        _betterPlayerController!.pause();
      } else {
        _betterPlayerController!.play();
      }
    }
  }

  // 处理拖动事件
// 处理拖动事件
void _onHorizontalDragUpdate(DragUpdateDetails details) {
  if (_betterPlayerController == null) return;

  final isFullScreen = _betterPlayerController?.isFullScreen ?? false;
  final currentPosition = _betterPlayerController!.videoPlayerController!.value.position;
  final videoLength = _betterPlayerController!.videoPlayerController!.value.duration ?? Duration.zero;

  // 根据是否全屏设置不同的拖动灵敏度
  final dragSensitivity = isFullScreen ? 0.5 : 0.5; // 适当调整灵敏度

  // 计算拖动的时间
  final dragTime = Duration(seconds: (details.primaryDelta! * dragSensitivity).round());
  final newPosition = currentPosition + dragTime;

  // 更新视频播放位置
  _betterPlayerController!.seekTo(
    newPosition > Duration.zero
      ? (newPosition < videoLength ? newPosition : videoLength)
      : Duration.zero,
  );
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
                : GestureDetector(
                    onDoubleTapDown: (details) => _onDoubleTap(details, context),
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    child: Column(
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
                                  '正在播放第 ${videoState.currentEpisodeIndex + 1} 集',
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
                                            _playEpisode(episode['url']);
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
      ),
    );
  }
}