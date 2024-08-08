import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController? controller;

  const VideoPlayerWidget({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: controller != null && controller!.value.isInitialized
          ? VideoPlayer(controller!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
