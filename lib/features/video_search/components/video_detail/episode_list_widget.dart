import 'package:flutter/material.dart';

class EpisodeListWidget extends StatelessWidget {
  final Map<String, dynamic> episodes;
  final Map<String, int> currentEpisodeIndices;
  final Function(String, int) onEpisodeTap;

  const EpisodeListWidget({
    Key? key,
    required this.episodes,
    required this.currentEpisodeIndices,
    required this.onEpisodeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final entry = episodes.entries.toList()[index];
              final lineName = entry.key;
              final lineEpisodes = entry.value as List<dynamic>;

              return Row(
                children: lineEpisodes.map<Widget>((episode) {
                  final episodeIndex = lineEpisodes.indexOf(episode);
                  final isSelected =
                      currentEpisodeIndices[lineName] == episodeIndex;

                  return GestureDetector(
                    onTap: () => onEpisodeTap(lineName, episodeIndex),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: isSelected ? Colors.black : Colors.grey[200],
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          episode['name'] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const Divider(
          // 添加边界线
          height: 3,
          color: Colors.black,
        ),
      ],
    );
  }
}
