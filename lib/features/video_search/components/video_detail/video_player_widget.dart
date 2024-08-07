import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final BetterPlayerController? controller;

  const VideoPlayerWidget({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: controller != null
          ? BetterPlayer(controller: controller!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
