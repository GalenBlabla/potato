import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class CustomControls extends StatelessWidget {
  final BetterPlayerController controller;

  const CustomControls({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 可以在这里添加其他控件，如进度条、全屏按钮等
      ],
    );
  }
}
