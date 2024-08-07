// lib/features/video_search/video_search_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:potato/core/state/search_state.dart';
import 'package:go_router/go_router.dart';

class VideoSearchPage extends StatefulWidget {
  final String query;

  const VideoSearchPage({required this.query, super.key});

  @override
  _VideoSearchPageState createState() => _VideoSearchPageState();
}

class _VideoSearchPageState extends State<VideoSearchPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchState = Provider.of<SearchState>(context, listen: false);
      searchState.searchVideos(widget.query); // 执行搜索
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      final searchState = Provider.of<SearchState>(context, listen: false);
      searchState.searchVideos(query);
      context.go('/search', extra: query); // 更新路由中的query参数
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.grey), // 设置返回按钮颜色
        title: Container(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _onSearchSubmitted(),
                ),
              ),
              TextButton(
                onPressed: _onSearchSubmitted,
                child: const Text(
                  '搜索',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: searchState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchState.hasError
                    ? const Center(child: Text('Error loading search results'))
                    : ListView.builder(
                        itemCount: searchState.searchResults.length,
                        itemBuilder: (context, index) {
                          final result = searchState.searchResults[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  context.pushNamed('VideoDetail',
                                      pathParameters: {
                                        'link': result['link']!
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          result['thumbnail'] ?? '',
                                          width: 100,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              result['title'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                '别名: ${result['alias'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                    color: Colors.black54)),
                                            Text(
                                                '主演: ${result['actors'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                    color: Colors.black54)),
                                            Text(
                                                '类型: ${result['genre'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                    color: Colors.black54)),
                                            Text(
                                                '地区: ${result['region'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                    color: Colors.black54)),
                                            Text(
                                                '年份: ${result['year'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                    color: Colors.black54)),
                                          ],
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
  }
}
