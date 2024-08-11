import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:potato/core/state/video_detail_state.dart';
import 'components/video_detail/episode_list_widget.dart';
import 'components/video_detail/video_title_widget.dart';
import 'components/video_detail/fijkplayer_widget.dart';

class VideoDetailPage extends StatefulWidget {
  final String link;
  const VideoDetailPage({required this.link, super.key});

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage>
    with TickerProviderStateMixin {
  FijkPlayer? _fijkPlayer;
  TabController? _tabController;
  final Map<String, int> _currentEpisodeIndices = {};

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

    _fijkPlayer = FijkPlayer();
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

    _fijkPlayer?.reset();

    try {
      final videoSource = await videoDetailState.getEpisodeInfo(url);
      final decryptedUrl = await videoDetailState.getDecryptedUrl(videoSource);

      await _fijkPlayer?.setDataSource(decryptedUrl, autoPlay: true);
      setState(() {}); // 更新UI，确保播放器显示

    } catch (e) {
      print('Error playing video: $e');
    }
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
    _fijkPlayer?.release();
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
            : videoDetailState.hasError || videoInfo == null
                ? const Center(child: Text('Error loading video information'))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FijkPlayerWidget(player: _fijkPlayer),
                        const SizedBox(height: 16),
                        VideoTitleWidget(title: videoInfo?['title']),
                        const SizedBox(height: 8),
                        if (videoInfo['episodes'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_tabController != null)
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: TabBar(
                                    controller: _tabController,
                                    isScrollable: true,
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
                                  height: 300, // 设置 TabBarView 的固定高度
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
      ),
    );
  }

}
