import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';

class FijkPlayerWidget extends StatefulWidget {
  final FijkPlayer? player;

  const FijkPlayerWidget({Key? key, this.player}) : super(key: key);

  @override
  _FijkPlayerWidgetState createState() => _FijkPlayerWidgetState();
}

class _FijkPlayerWidgetState extends State<FijkPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: Colors.black, // 设置背景为黑色，填充未被视频覆盖的部分
        child: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9, // 设置视频宽高比为16:9
            child: widget.player != null
                ? FijkView(
                    player: widget.player!,
                    fit: FijkFit.contain, // 保持视频比例，不拉伸
                    color: Colors.black,
                    panelBuilder: fijkPanel2Builder(
                      fill: false, // 是否填充整个播放器区域
                      duration: 4000, // 控制面板自动隐藏的时间（毫秒）
                      doubleTap: true, // 启用双击播放/暂停功能
                      snapShot: false, // 是否启用截图功能
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
