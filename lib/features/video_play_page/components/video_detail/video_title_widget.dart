import 'package:flutter/material.dart';

class VideoTitleWidget extends StatelessWidget {
  final String? title;

  const VideoTitleWidget({Key? key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (title == null) return const SizedBox.shrink();

    // 使用正则表达式分离标题和评分，基于“在线观看”关键词
    final cleanTitle = title!;
    final RegExp regex = RegExp(r'^(.*)(在线观看\s*([\d.]+))$');
    final match = regex.firstMatch(cleanTitle);
    final videoTitle = match?.group(1)?.trim() ?? '';
    final rating = match?.group(3) ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: videoTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // 标题使用深灰色
              ),
            ),
            if (rating.isNotEmpty)
              TextSpan(
                text: ' 评分：$rating',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey, // 评分使用灰色
                ),
              ),
          ],
        ),
      ),
    );
  }
}
