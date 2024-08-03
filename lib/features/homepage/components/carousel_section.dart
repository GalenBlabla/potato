import 'package:flutter/material.dart';

class CarouselSection extends StatelessWidget {
  final List<Map<String, dynamic>> carouselVideos;
  final PageController pageController;

  const CarouselSection({
    Key? key,
    required this.carouselVideos,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: pageController,
        itemCount: carouselVideos.length,
        itemBuilder: (context, index) {
          final video = carouselVideos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    video['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
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
                  left: 10,
                  bottom: 10,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      video['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
