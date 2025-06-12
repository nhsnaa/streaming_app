import 'package:flutter/material.dart';
import 'package:streaming_app/services/tmdb_service1.dart';
import 'package:streaming_app/widgets/detail_page.dart';

class TrendingTVSection extends StatefulWidget {
  const TrendingTVSection({super.key});

  @override
  State<TrendingTVSection> createState() => _TrendingTVSectionState();
}

class _TrendingTVSectionState extends State<TrendingTVSection> {
  List<dynamic> trendingTV = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTrendingTV();
  }

  Future<void> loadTrendingTV() async {
    try {
      final shows = await TMDBService().fetchTrendingTV();
      if (!mounted) return;
      setState(() {
        trendingTV = shows;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading trending TV: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || trendingTV.isEmpty) {
      return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
    }

    final featured = trendingTV[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🎬 Featured Banner
        Stack(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://image.tmdb.org/t/p/original${featured['backdrop_path']}'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    featured['name'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (featured['overview'] as String).length > 120
                        ? '${featured['overview'].substring(0, 120)}...'
                        : featured['overview'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(item: featured)));
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Watch Now"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 📺 Horizontal TV Scroll
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trendingTV.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final show = trendingTV[index];
              final imageUrl = 'https://image.tmdb.org/t/p/w500${show['backdrop_path']}';

              return Container(
                width: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Colors.black87, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            show['name'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (show['overview'] as String).length > 100
                                ? '${show['overview'].substring(0, 100)}...'
                                : show['overview'],
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => DetailPage(item: show)),
                              );
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
