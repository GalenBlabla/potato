import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecommendedSection extends StatelessWidget {
  final List<Map<String, dynamic>> recommendedVideos;

  const RecommendedSection({
    Key? key,
    required this.recommendedVideos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      // 检查 recommendedVideos 是否为空
    if (recommendedVideos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final groups = _groupVideosByCategory(recommendedVideos);

    if (recommendedVideos.isEmpty) {
      return const Center(child: Text('No recommended videos available'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groups.entries.map((entry) {
          final category = entry.key;
          final videos = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200, // 设置一个固定的高度
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return GestureDetector(
                        onTap: () {
                          context.pushNamed('VideoDetail',
                              pathParameters: {'link': video['link']!});
                        },
                        child: Container(
                          width: 140, // 设置图片容器的宽度
                          margin: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      video['image'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 50,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black54,
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        video['title'] ?? 'No Title',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 分组函数
  Map<String, List<Map<String, dynamic>>> _groupVideosByCategory(
      List<Map<String, dynamic>> videos) {
    const categories = ['热播动漫推荐', '最新日本动漫', '最新国产动漫', '最新动漫电影', '最新欧美动漫'];
    final Map<String, List<Map<String, dynamic>>> groupedVideos = {};

    for (var i = 0; i < categories.length; i++) {
      final start = i * 12;
      final end = start + 12;
      groupedVideos[categories[i]] =
          videos.sublist(start, end < videos.length ? end : videos.length);
    }

    return groupedVideos;
  }
}
