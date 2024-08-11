import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:potato/core/state/video_detail_state.dart';
import 'components/video_detail/episode_list_widget.dart';
import 'components/video_detail/video_title_widget.dart';
import 'components/video_detail/fijkplayer_widget.dart';

/// 视频详情页面，显示视频播放以及相关的剧集信息
class VideoDetailPage extends StatefulWidget {
  final String link; // 视频链接，传递给页面，用于获取视频详情
  const VideoDetailPage({required this.link, super.key});

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage>
    with TickerProviderStateMixin {
  FijkPlayer? _fijkPlayer; // FijkPlayer播放器实例
  TabController? _tabController; // TabController 用于管理 TabBar 和 TabBarView 的联动
  final Map<String, int> _currentEpisodeIndices = {}; // 保存每个剧集行当前播放的集数索引

  @override
  void initState() {
    super.initState();
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black, // 设置状态栏颜色为黑色
        statusBarIconBrightness: Brightness.light, // 设置状态栏图标为浅色
      ),
    );
    // 在第一次渲染之后初始化播放器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 获取 VideoDetailState 对象
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);
    // 如果视频信息已加载，初始化 TabController
    if (videoDetailState.videoInfo != null) {
      _tabController = TabController(
        length: videoDetailState.videoInfo!['episodes'].length, // 剧集行的数量
        vsync: this, // 必须提供 TickerProvider（即当前的 State）
      );
    }
  }

  /// 初始化播放器并加载视频信息
  Future<void> _initializePlayer() async {
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);
    // 从给定链接获取视频信息
    await videoDetailState.fetchVideoInfo(widget.link);

    // 如果组件已经被卸载，直接返回
    if (!mounted) return;

    // 根据获取到的视频信息初始化 TabController
    setState(() {
      _tabController = TabController(
        length: videoDetailState.videoInfo!['episodes'].length,
        vsync: this,
      );
    });

    // 创建 FijkPlayer 实例
    _fijkPlayer = FijkPlayer();
    // 播放第一个剧集
    _playEpisodeAtIndex(0);
  }

  /// 播放指定索引的剧集
  Future<void> _playEpisodeAtIndex(int index) async {
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);
    // 如果视频信息或剧集为空，直接返回
    if (videoDetailState.videoInfo == null ||
        videoDetailState.videoInfo!['episodes'] == null) return;

    final episodes = videoDetailState.videoInfo!['episodes'];
    // 如果索引超出剧集数量，直接返回
    if (index >= episodes.entries.length) return;

    // 获取当前选中的剧集 URL
    final entry = episodes.entries.toList()[index];
    final episode = entry.value[0];
    final url = episode['url'];

    // 播放选中的剧集
    await _playEpisode(url);
    // 更新当前播放的剧集索引
    videoDetailState.setCurrentEpisodeIndex(index);
  }

  /// 播放给定 URL 的视频
  Future<void> _playEpisode(String url) async {
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);

    try {
      // 先重置播放器，确保它处于 idle 状态
      await _fijkPlayer?.reset();
      // 获取视频源信息，并解密获取真实播放链接
      final videoSource = await videoDetailState.getEpisodeInfo(url);
      final decryptedUrl = await videoDetailState.getDecryptedUrl(videoSource);

      // 设置数据源并自动播放
      await _fijkPlayer?.setDataSource(decryptedUrl, autoPlay: true);
      setState(() {}); // 更新 UI，确保播放器显示
    } catch (e) {
      if (kDebugMode) {
        print('Error playing video: $e'); // 打印错误信息
      }
    }
  }

  /// 当用户点击某一集时调用
  void _onEpisodeTap(String lineName, int episodeIndex) {
    setState(() {
      // 更新当前行的播放集数索引
      _currentEpisodeIndices[lineName] = episodeIndex;
    });

    // 播放选中的集数
    final videoDetailState =
        Provider.of<VideoDetailState>(context, listen: false);
    print(videoDetailState); // 打印 videoDetailState 对象信息，供调试使用
    final episodes = videoDetailState.videoInfo!['episodes'];
    final episode = episodes[lineName][episodeIndex];
    final url = episode['url'];
    _playEpisode(url); // 播放选中的剧集
  }

  @override
  void dispose() {
    // 释放播放器资源
    _fijkPlayer?.release();
    // 释放 TabController 资源
    _tabController?.dispose();

    // 恢复系统状态栏样式
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
            ? const Center(child: CircularProgressIndicator()) // 显示加载中的进度条
            : videoDetailState.hasError || videoInfo == null
                ? const Center(
                    child: Text('Error loading video information')) // 显示加载错误信息
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FijkPlayerWidget(player: _fijkPlayer), // 视频播放器组件
                        const SizedBox(height: 16), // 增加间距
                        VideoTitleWidget(title: videoInfo['title']), // 显示视频标题
                        const SizedBox(height: 8), // 增加间距
                        if (videoInfo['episodes'] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_tabController != null)
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: TabBar(
                                    controller: _tabController, // 控制 TabBar
                                    isScrollable: true, // 使 TabBar 可滚动
                                    indicatorColor: Colors.black, // 指示器颜色
                                    labelColor: Colors.black, // 选中的标签颜色
                                    unselectedLabelColor:
                                        Colors.grey, // 未选中的标签颜色
                                    indicatorWeight: 2.0, // 指示器厚度
                                    labelStyle: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    tabs: videoInfo['episodes']
                                        .keys
                                        .map<Widget>((lineName) =>
                                            Tab(text: lineName)) // 显示每一行的名称
                                        .toList(),
                                  ),
                                ),
                              const Divider(
                                height: 1,
                                color: Colors.grey, // 分割线颜色
                              ),
                              if (_tabController != null)
                                SizedBox(
                                  height: 300, // 设置 TabBarView 的固定高度
                                  child: TabBarView(
                                    controller: _tabController, // 控制 TabBarView
                                    children: videoInfo['episodes']
                                        .entries
                                        .map<Widget>((entry) {
                                      return EpisodeListWidget(
                                        episodes: {
                                          entry.key: entry.value
                                        }, // 当前行的剧集列表
                                        currentEpisodeIndices:
                                            _currentEpisodeIndices, // 当前播放的集数索引
                                        onEpisodeTap: _onEpisodeTap, // 点击剧集后的回调
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
