// lib/features/video_search/video_search_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Potato/core/state/video_state.dart';
import 'package:go_router/go_router.dart';

class VideoSearchPage extends StatelessWidget {
  const VideoSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final videoState = Provider.of<VideoState>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Anime-Style',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextField(
                onSubmitted: (query) {
                  videoState.searchVideos(query);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                  hintText: 'Search for anime...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  contentPadding: const EdgeInsets.all(15.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: videoState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : videoState.hasError
                    ? const Center(child: Text('Error loading search results'))
                    : ListView.builder(
                        itemCount: videoState.searchResults.length,
                        itemBuilder: (context, index) {
                          final result = videoState.searchResults[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  context.go('/video_detail/${result['link']}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                            Text('别名: ${result['alias'] ?? 'N/A'}', style: const TextStyle(color: Colors.black54)),
                                            Text('主演: ${result['actors'] ?? 'N/A'}', style: const TextStyle(color: Colors.black54)),
                                            Text('类型: ${result['genre'] ?? 'N/A'}', style: const TextStyle(color: Colors.black54)),
                                            Text('地区: ${result['region'] ?? 'N/A'}', style: const TextStyle(color: Colors.black54)),
                                            Text('年份: ${result['year'] ?? 'N/A'}', style: const TextStyle(color: Colors.black54)),
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
