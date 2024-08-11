import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:potato/core/state/category_video_state.dart';
import 'package:go_router/go_router.dart';

/// 动漫分类页面组件，支持无限滚动加载视频列表
class AnimeCategoryPage extends StatefulWidget {
  final int categoryIndex; // 分类索引

  const AnimeCategoryPage({
    super.key,
    required this.categoryIndex,
  });

  @override
  _AnimeCategoryPageState createState() => _AnimeCategoryPageState();
}

class _AnimeCategoryPageState extends State<AnimeCategoryPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // 初始加载数据
    _fetchInitialData();

    // 监听滚动事件，当滚动到列表底部时加载更多数据
    _scrollController.addListener(_onScroll);
  }

  void _fetchInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryVideoState>().fetchCategoryVideos(
            context
                .read<CategoryVideoState>()
                .getCategoryUrlByIndex(widget.categoryIndex),
          );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final categoryVideoState = context.read<CategoryVideoState>();
      if (!categoryVideoState.isLoadingCategory &&
          categoryVideoState.hasMoreVideos) {
        categoryVideoState.loadMoreVideos(
          categoryVideoState.getCategoryUrlByIndex(widget.categoryIndex),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryVideoState>(
      builder: (context, categoryVideoState, child) {
        final videos =
            categoryVideoState.getCategoryVideosByIndex(widget.categoryIndex);

        if (categoryVideoState.isLoadingCategory && videos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (videos.isEmpty) {
          return const Center(child: Text('No videos available.'));
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: videos.length + 1,
          itemBuilder: (context, index) {
            if (index == videos.length) {
              return categoryVideoState.hasMoreVideos
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            final video = videos[index];
            return GestureDetector(
              onTap: () {
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
        );
      },
    );
  }
}
