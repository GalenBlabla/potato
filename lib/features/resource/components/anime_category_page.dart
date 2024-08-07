// lib/features/resource/components/anime_category_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:potato/core/state/category_video_state.dart';
import 'package:go_router/go_router.dart';

/// 动漫分类页面组件
class AnimeCategoryPage extends StatelessWidget {
  final int categoryIndex; // 分类索引
  final VoidCallback onLoadMore; // 加载更多视频的回调函数
  final VoidCallback onLoadPrevious; // 加载上一页视频的回调函数

  const AnimeCategoryPage({
    super.key,
    required this.categoryIndex,
    required this.onLoadMore,
    required this.onLoadPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryVideoState>(
      builder: (context, categoryVideoState, child) {
        // 根据分类索引获取视频列表
        final videos =
            categoryVideoState.getCategoryVideosByIndex(categoryIndex);

        // 显示加载指示器，如果正在加载并且视频列表为空
        if (categoryVideoState.isLoadingCategory && videos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        // 显示没有视频的消息，如果视频列表为空
        else if (videos.isEmpty) {
          return const Center(child: Text('No videos available.'));
        }
        // 显示视频列表
        else {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.pixels >=
                      scrollNotification.metrics.maxScrollExtent - 200 &&
                  !categoryVideoState.isLoadingCategory &&
                  categoryVideoState.hasMoreVideos) {
                onLoadMore();
              } else if (scrollNotification.metrics.pixels <= 200 &&
                  !categoryVideoState.isLoadingCategory &&
                  categoryVideoState.currentPage > 1) {
                onLoadPrevious();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: videos.length + 1,
              itemBuilder: (context, index) {
                if (index == videos.length) {
                  return categoryVideoState.hasMoreVideos
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }

                final video = videos[index];
                return GestureDetector(
                  onTap: () {
                    // 点击视频时导航到视频详情页面
                    context.pushNamed('VideoDetail',
                        pathParameters: {'link': video['link']!});
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Image.network(
                            video['image'],
                            width: 80,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 150,
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                video['description'] ?? 'No Description',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
