import 'dart:async';
import 'package:flutter/material.dart';
import 'package:streaming_app/services/tmdb_service1.dart';
import 'package:streaming_app/widgets/detail_page.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> trendingMovies = [];
  int currentIndex = 0;
  Timer? autoScrollTimer;

  @override
  void initState() {
    super.initState();
    fetchTrending();
    startAutoScroll();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    autoScrollTimer?.cancel();
    super.dispose();
  }

  // 🔄 Fetch trending movies from TMDB
  Future<void> fetchTrending() async {
    final movies = await TMDBService().fetchTrendingMovies();
    if (!mounted) return;
    setState(() => trendingMovies = movies.take(15).toList()); // Limit to 15
  }

  // ⏱️ Auto scroll every 4 seconds
  void startAutoScroll() {
    autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_scrollController.hasClients && trendingMovies.isNotEmpty) {
        currentIndex = (currentIndex + 1) % trendingMovies.length;
        _scrollController.animateTo(
          currentIndex * 320.0, // adjust to item width
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ⬅️➡️ Scroll manually
  void scrollTo(int direction) {
    if (trendingMovies.isEmpty) return;

    currentIndex = (currentIndex + direction) % trendingMovies.length;
    if (currentIndex < 0) currentIndex = trendingMovies.length - 1;

    _scrollController.animateTo(
      currentIndex * 320.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (trendingMovies.isEmpty) {
      return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '🔥 Trending Now',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: trendingMovies.length,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                itemBuilder: (context, index) {
                  final movie = trendingMovies[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailPage(item: movie)),
                    ),
                    child: Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://image.tmdb.org/t/p/w780${movie['backdrop_path']}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // 🎬 Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 🏷️ Info overlay
                          Positioned(
                            left: 12,
                            bottom: 12,
                            right: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Label
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'TRENDING',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 3),

                                // Title
                                Text(
                                  movie['title'] ?? movie['name'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // Review/Rating
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      (movie['vote_average'] as double).toStringAsFixed(1),
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),
                                Text(
                                  (movie['overview'] as String).length > 80
                                      ? '${movie['overview'].substring(0, 80)}...'
                                      : movie['overview'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
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

              // ◀️ Scroll Left Button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                  onPressed: () => scrollTo(-1),
                ),
              ),

              // ▶️ Scroll Right Button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                  onPressed: () => scrollTo(1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
