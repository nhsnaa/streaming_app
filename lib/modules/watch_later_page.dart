import 'package:flutter/material.dart';
import '../services/watchlist_manager.dart';
import '../widgets/movie_info_dialog.dart';
import '../widgets/detail_page.dart';

class WatchLaterPage extends StatefulWidget {
  const WatchLaterPage({super.key});

  @override
  State<WatchLaterPage> createState() => _WatchLaterPageState();
}

class _WatchLaterPageState extends State<WatchLaterPage> {
  List<Map<String, dynamic>> _movies = [];
  List<Map<String, dynamic>> _tvShows = [];
  String _sortOption = 'title'; // Default sort option

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  // Load the watchlist and group into movies and TV shows
  Future<void> _loadWatchlist() async {
    final list = await WatchlistManager.getWatchlist();
    List<Map<String, dynamic>> movies = [];
    List<Map<String, dynamic>> tvShows = [];

    for (var item in list) {
      if (item.containsKey('title')) {
        movies.add(item);
      } else {
        tvShows.add(item);
      }
    }

    _sortList(movies);
    _sortList(tvShows);

    setState(() {
      _movies = movies;
      _tvShows = tvShows;
    });
  }

  // Sort list by title or rating
  void _sortList(List<Map<String, dynamic>> list) {
    list.sort((a, b) {
      if (_sortOption == 'rating') {
        return ((b['vote_average'] ?? 0) as num)
            .compareTo((a['vote_average'] ?? 0) as num);
      }
      return (a['title'] ?? a['name'] ?? '').toLowerCase().compareTo(
            (b['title'] ?? b['name'] ?? '').toLowerCase(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _movies.isEmpty && _tvShows.isEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Watch Later'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _sortOption = value);
              _sortList(_movies);
              _sortList(_tvShows);
            },
            icon: const Icon(Icons.sort, color: Colors.white),
            color: Colors.grey[900],
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'title',
                child: Text('Sort by Title',
                style: TextStyle(color: Colors.white70)
                ),
              ),
              const PopupMenuItem(
                value: 'rating',
                child: Text('Sort by Rating', 
                style: TextStyle(color: Colors.white70)
                ),
              ),
            ],
          ),
        ],
      ),
      body: isEmpty
          ? const Center(
              child: Text(
                'No items saved for later.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView(
              children: [
                if (_movies.isNotEmpty)
                  _buildSection('Movies', _movies),
                if (_tvShows.isNotEmpty)
                  _buildSection('TV Shows', _tvShows),
              ],
            ),
    );
  }

  // Build section for movies or TV shows
  Widget _buildSection(String title, List<Map<String, dynamic>> list) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          // List of items
          ...list.map((item) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      item['poster_path'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w92${item['poster_path']}',
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const SizedBox(
                              width: 60,
                              child: Icon(Icons.movie, color: Colors.white),
                            ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 60,
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${(item['vote_average'] ?? 0).toStringAsFixed(1)} ★',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.amber, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    item['title'] ?? item['name'] ?? 'No title',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark_remove_outlined,
                        color: Colors.white),
                    onPressed: () async {
                      // Remove item from watchlist and reload
                      await WatchlistManager.removeFromWatchlist(item['id']);
                      _loadWatchlist();
                    },
                  ),
                  onTap: () async {
                    // Open MovieInfoDialog
                    final shouldPlay = await showDialog<bool>(
                      context: context,
                      builder: (_) => MovieInfoDialog(item: item),
                    );
                    if (shouldPlay == true && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(item: item),
                        ),
                      );
                    }
                  },
                ),
              )),
        ],
      ),
    );
  }
}
