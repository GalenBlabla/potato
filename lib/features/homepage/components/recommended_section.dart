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
    if (recommendedVideos.isEmpty) {
      return const Center(child: Text('No recommended videos available'));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: 0.7,
        ),
        itemCount: recommendedVideos.length,
        itemBuilder: (context, index) {
          final video = recommendedVideos[index];
          return GestureDetector(
            onTap: () {
              context.pushNamed('VideoDetail', pathParameters: {'link': video['link']!});
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Image.network(
                    video['image'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
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
                  Container(
                    width: double.infinity,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
