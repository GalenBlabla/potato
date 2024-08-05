import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
            child: FutureBuilder<bool>(
              future: _checkImage(video['image']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink(); // Or show a loading indicator
                }
                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
                  return const SizedBox.shrink(); // Do not display the element
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        video['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool> _checkImage(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
