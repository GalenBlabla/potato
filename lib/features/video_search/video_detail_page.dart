import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/services.dart';
import 'package:potato/core/state/video_detail_state.dart';
import 'components/video_detail/video_player_widget.dart';
import 'components/video_detail/episode_list_widget.dart';
import 'components/video_detail/video_title_widget.dart';
import 'components/custom_controls.dart';

class VideoDetailPage extends StatefulWidget {
  final String link;
  const VideoDetailPage({required this.link, super.key});

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage>
    with TickerProviderStateMixin {
  BetterPlayerController? _betterPlayerController;
  TabController? _tabController;
  Map<String, int> _currentEpisodeIndices = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);
    if (videoDetailState.videoInfo != null) {
      _tabController = TabController(
        length: videoDetailState.videoInfo!['episodes'].length,
        vsync: this,
      );
    }
  }

  Future<void> _initializePlayer() async {
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);
    await videoDetailState.fetchVideoInfo(widget.link);

    if (!mounted) return;

    setState(() {
      _tabController = TabController(
        length: videoDetailState.videoInfo!['episodes'].length,
        vsync: this,
      );
    });

    _playEpisodeAtIndex(0);
  }

  Future<void> _playEpisodeAtIndex(int index) async {
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);
    if (videoDetailState.videoInfo == null ||
        videoDetailState.videoInfo!['episodes'] == null) return;

    final episodes = videoDetailState.videoInfo!['episodes'];
    if (index >= episodes.entries.length) return;

    final entry = episodes.entries.toList()[index];
    final episode = entry.value[0];
    final url = episode['url'];

    await _playEpisode(url);
    videoDetailState.setCurrentEpisodeIndex(index);
  }

  Future<void> _playEpisode(String url) async {
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);

    _betterPlayerController?.pause();
    _betterPlayerController?.dispose();

    try {
      final videoSource = await videoDetailState.getEpisodeInfo(url);
      final decryptedUrl = await videoDetailState.getDecryptedUrl(videoSource);
      final betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        decryptedUrl,
      );

      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          aspectRatio: 16 / 9,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControlsOnInitialize: false,
            customControlsBuilder: (controller, onControlsVisibilityChanged) {
              return CustomControls(controller: controller);
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

      setState(() {}); // 更新UI，确保播放器显示
    } catch (e) {
      print('Error playing video: $e');
    }
  }

  void _playNextEpisode() {
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);
    if (videoDetailState.videoInfo == null ||
        videoDetailState.videoInfo!['episodes'] == null) return;

    final episodes = videoDetailState.videoInfo!['episodes'];
    if (videoDetailState.currentEpisodeIndex + 1 >= episodes.entries.length)
      return;

    final nextIndex = videoDetailState.currentEpisodeIndex + 1;
    _playEpisodeAtIndex(nextIndex);
  }

  void _onEpisodeTap(String lineName, int episodeIndex) {
    setState(() {
      _currentEpisodeIndices[lineName] = episodeIndex;
    });

    // 播放选中的集数
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);
    final episodes = videoDetailState.videoInfo!['episodes'];
    final episode = episodes[lineName][episodeIndex];
    final url = episode['url'];
    _playEpisode(url);
  }

  @override
  void dispose() {
    // 先暂停播放器并释放资源
    _betterPlayerController?.pause();
    _betterPlayerController?.dispose();

    _tabController?.dispose();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoDetailState = Provider.of<VideoDetailState>(context);
    final videoInfo = videoDetailState.videoInfo;

    return Scaffold(
      body: SafeArea(
        child: videoDetailState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : videoDetailState.hasError
                ? const Center(child: Text('Error loading video information'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VideoPlayerWidget(controller: _betterPlayerController),
                      const SizedBox(height: 16),
                      VideoTitleWidget(title: videoInfo?['title']),
                      const SizedBox(height: 8),
                      if (videoInfo != null && videoInfo['episodes'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_tabController != null)
                              Container(
                                alignment: Alignment.centerLeft, // 设置TabBar靠左
                                child: TabBar(
                                  controller: _tabController,
                                  isScrollable: true, // 使TabBar可滚动
                                  indicatorColor: Colors.black,
                                  labelColor: Colors.black,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorWeight: 2.0,
                                  labelStyle: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  tabs: videoInfo['episodes']
                                      .keys
                                      .map<Widget>(
                                          (lineName) => Tab(text: lineName))
                                      .toList(),
                                ),
                              ),
                            const Divider(
                              height: 1,
                              color: Colors.grey,
                            ),
                            if (_tabController != null)
                              SizedBox(
                                height: 60, // 适当调整高度
                                child: TabBarView(
                                  controller: _tabController,
                                  children: videoInfo['episodes']
                                      .entries
                                      .map<Widget>((entry) {
                                    return EpisodeListWidget(
                                      episodes: {entry.key: entry.value},
                                      currentEpisodeIndices:
                                          _currentEpisodeIndices,
                                      onEpisodeTap: _onEpisodeTap,
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
      ),
    );
  }
}
