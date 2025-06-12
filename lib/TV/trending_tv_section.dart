import 'dart:async';
import 'package:flutter/material.dart';
import 'package:streaming_app/services/tmdb_service1.dart';
import 'package:streaming_app/widgets/detail_page.dart';

class TrendingTVPage extends StatefulWidget {
  const TrendingTVPage({super.key});

  @override
  State<TrendingTVPage> createState() => _TrendingTVPageState();
}

class _TrendingTVPageState extends State<TrendingTVPage> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> trendingTV = []; // ✅ Correct variable for TV
  int currentIndex = 0;
  Timer? autoScrollTimer;

  @override
  void initState() {
    super.initState();
    fetchTrendingTV();
    startAutoScroll();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    autoScrollTimer?.cancel();
    super.dispose();
  }

  // 🔄 Fetch trending TV shows
  Future<void> fetchTrendingTV() async {
    final tvShows = await TMDBService().fetchTrendingTV();
    if (!mounted) return;
    setState(() => trendingTV = tvShows.take(10).toList());
  }

  // ⏱️ Auto scroll every 4 seconds
  void startAutoScroll() {
    autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_scrollController.hasClients && trendingTV.isNotEmpty) {
        currentIndex = (currentIndex + 1) % trendingTV.length;
        _scrollController.animateTo(
          currentIndex * 320.0,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ⬅️➡️ Manual scroll
  void scrollTo(int direction) {
    if (trendingTV.isEmpty) return;

    currentIndex = (currentIndex + direction) % trendingTV.length;
    if (currentIndex < 0) currentIndex = trendingTV.length - 1;

    _scrollController.animateTo(
      currentIndex * 320.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (trendingTV.isEmpty) {
      return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '📺 Trending TV Shows',
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
                itemCount: trendingTV.length,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                itemBuilder: (context, index) {
                  final tv = trendingTV[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailPage(item: tv)),
                    ),
                    child: Container(
                      width: 300,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://image.tmdb.org/t/p/w780${tv['backdrop_path']}',
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'TRENDING',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  tv['name'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      (tv['vote_average'] as double).toStringAsFixed(1),
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),
                                Text(
                                  (tv['overview'] as String).length > 80
                                      ? '${tv['overview'].substring(0, 80)}...'
                                      : tv['overview'],
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

              // ◀️ Left
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                  onPressed: () => scrollTo(-1),
                ),
              ),

              // ▶️ Right
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
