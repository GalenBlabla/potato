import 'package:flutter/material.dart';

class EpisodeHeaderWidget extends StatelessWidget {
  final int currentEpisodeIndex;

  const EpisodeHeaderWidget({Key? key, required this.currentEpisodeIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '播放列表:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(
            '正在播放第 ${currentEpisodeIndex + 1} 集',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
