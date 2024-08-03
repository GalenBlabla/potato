// lib/features/video_search/video_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:better_player/better_player.dart';
import 'package:Potato/core/state/video_state.dart';
import 'package:Potato/data/api/video_api_service.dart';

class VideoDetailPage extends StatefulWidget {
  final String link;
  const VideoDetailPage({required this.link, super.key});

  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  BetterPlayerController? _betterPlayerController;
  String? _currentEpisodeUrl;
  int _currentEpisodeIndex = 0;

  @override
  void initState() {
    super.initState();
    final videoState = Provider.of<VideoState>(context, listen: false);
    videoState.fetchVideoInfo(widget.link);
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _playEpisode(String episodeUrl) async {
    try {
      final videoSource = await VideoApiService().getEpisodeInfo(episodeUrl);
      final decryptedUrl = await VideoApiService().getDecryptedUrl(videoSource);

      final betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        decryptedUrl,
      );

      _betterPlayerController?.dispose();

      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          aspectRatio: 16 / 9,
          eventListener: (event) {
            if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
              _playNextEpisode();
            }
          },
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );

      setState(() {
        _currentEpisodeUrl = episodeUrl;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _playEpisodeAtIndex(int index) async {
    final videoState = Provider.of<VideoState>(context, listen: false);
    final videoInfo = videoState.videoInfo;

    if (videoInfo != null && videoInfo['episodes'] != null) {
      final episodes = videoInfo['episodes'];
      final entry = episodes.entries.toList()[index];
      final episode = entry.value[0];

      await _playEpisode(episode['url']);
    }
  }

  void _playNextEpisode() {
    final videoState = Provider.of<VideoState>(context, listen: false);
    final videoInfo = videoState.videoInfo;

    if (videoInfo != null && videoInfo['episodes'] != null) {
      final episodes = videoInfo['episodes'];
      final episodesCount = episodes.entries.length;
      if (_currentEpisodeIndex + 1 < episodesCount) {
        _currentEpisodeIndex++;
        _playEpisodeAtIndex(_currentEpisodeIndex);
      } else {
        print('No more episodes to play.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoState = Provider.of<VideoState>(context);
    final videoInfo = videoState.videoInfo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Detail'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: videoState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : videoState.hasError
              ? const Center(child: Text('Error loading video information'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _betterPlayerController != null
                          ? BetterPlayer(controller: _betterPlayerController!)
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
                              'Now Playing: Episode ${_currentEpisodeIndex + 1}',
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
                                        setState(() {
                                          _currentEpisodeIndex = videoInfo['episodes'].entries.toList().indexOf(entry);
                                        });
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
      floatingActionButton: videoInfo != null
          ? FloatingActionButton(
              onPressed: () {
                if (_currentEpisodeUrl == null) {
                  _playEpisodeAtIndex(_currentEpisodeIndex);
                } else {
                  setState(() {
                    if (_betterPlayerController != null &&
                        (_betterPlayerController!.isPlaying() ?? false)) {
                      _betterPlayerController!.pause();
                    } else {
                      _betterPlayerController!.play();
                    }
                  });
                }
              },
              child: Icon(
                _betterPlayerController != null &&
                        (_betterPlayerController!.isPlaying() ?? false)
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            )
          : Container(),
    );
  }
}
