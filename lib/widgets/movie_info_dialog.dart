import 'package:flutter/material.dart';
import 'package:streaming_app/services/watchlist_manager.dart';
import '../services/tmdb_service1.dart';
import '../widgets/detail_page.dart';

class MovieInfoDialog extends StatefulWidget {
  final dynamic item;

  const MovieInfoDialog({super.key, required this.item});

  @override
  State<MovieInfoDialog> createState() => _MovieInfoDialogState();
}

class _MovieInfoDialogState extends State<MovieInfoDialog> {
  Map<int, String> genreMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    final isMovie = widget.item['title'] != null;
    final genres = isMovie
        ? await TMDBService().fetchMovieGenres()
        : await TMDBService().fetchTVGenres();

    setState(() {
      genreMap = {for (var g in genres) g['id']: g['name']};
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final title = item['title'] ?? item['name'] ?? 'No title';
    final overview = item['overview'] ?? 'No overview';
    final posterPath = item['poster_path'];
    final releaseDate = item['release_date'] ?? item['first_air_date'] ?? 'N/A';
    final voteAverage = item['vote_average'] != null
        ? (item['vote_average'] as num).toStringAsFixed(1)
        : 'N/A';
    final originalLanguage = item['original_language']?.toUpperCase() ?? 'N/A';

    final List<int> genreIds = List<int>.from(item['genre_ids'] ?? []);
    final List<String> genreNames =
        genreIds.map((id) => genreMap[id] ?? 'Unknown').toList();
    final String genreText = genreNames.join(', ');

    return Dialog(
      backgroundColor: const Color.fromARGB(255, 41, 38, 38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: 600,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster with Watch Later icon
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 300,
                              
                              color: Colors.grey[900],
                              child: posterPath != null
                                  ? Image.network(
                                      'https://image.tmdb.org/t/p/w500$posterPath',
                                      height: 250,
                                      
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 50,
                                      ),
                                    ),
                            ),
                          ),
                          // Bookmark icon (Watch Later)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder<bool>(
                              future:
                                  WatchlistManager.isInWatchlist(item['id']),
                              builder: (context, snapshot) {
                                final isSaved = snapshot.data ?? false;
                                return IconButton(
                                  icon: Icon(
                                    isSaved
                                        ? Icons.bookmark_added
                                        : Icons.bookmark_add_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () async {
                                    if (isSaved) {
                                      await WatchlistManager.removeFromWatchlist(
                                          item['id']);
                                    } else {
                                      await WatchlistManager.addToWatchlist(
                                          item);
                                    }
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),

                      // Details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Release: $releaseDate',
                              style: const TextStyle(color: Colors.white70)),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '$voteAverage/10',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          Text('Language: $originalLanguage',
                              style: const TextStyle(color: Colors.white70)),
                          Text('Genres: $genreText',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Overview text
                      Text(
                        overview,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 20),

                      // Play trailer button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(item: item),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.black),
                        label: const Text("Play Trailer",
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
