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
  bool _isExpanded = false; // 🔽 Controls overview expansion

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
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: 600,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      children: [
                        // 🔳 Left: Poster
                        Expanded(
                          flex: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: double.infinity,
                              color: Colors.grey[900],
                              child: posterPath != null
                                  ? Image.network(
                                      'https://image.tmdb.org/t/p/w500$posterPath',
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
                        ),

                        const SizedBox(width: 20),

                        // 📝 Right: Info Section
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🎬 Title
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                //Text('Release: ${item['release_date']}', style: TextStyle(color: Colors.white70)),
                                // ℹ️ Metadata (Release, Rating, Lang, Genre)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow('Release Date:', releaseDate),
                                    _buildDetailRowWithIcon(Icons.star, '$voteAverage/10'),
                                    _buildDetailRow('Language:', originalLanguage),
                                    _buildDetailRow('Genres:', genreText),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // 📄 Overview Section with Read More
                                const Text(
                                  'Overview:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  overview,
                                  maxLines: _isExpanded ? null : 4,
                                  overflow:
                                      _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(color: Colors.white70, height: 1.5),
                                ),

                                // 🔽 Read More Toggle
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                                  child: Text(
                                    _isExpanded ? 'Show less ▲' : 'Read more ▼',
                                    style: const TextStyle(
                                        color: Colors.lightBlueAccent),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // ▶️ Play Trailer Button
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlueAccent,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => DetailPage(item: item)),
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
                      ],
                    ),

                    // 🔖 Floating Bookmark Icon (Top Right)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: FutureBuilder<bool>(
                        future: WatchlistManager.isInWatchlist(item['id']),
                        builder: (context, snapshot) {
                          final isSaved = snapshot.data ?? false;
                          return Material(
                            color: const Color.fromARGB(255, 41, 38, 38),
                            borderRadius: BorderRadius.circular(12),
                            child: IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark_added
                                    : Icons.bookmark_add_outlined,
                                color: Colors.redAccent,
                                size: 25,
                              ),
                              onPressed: () async {
                                if (isSaved) {
                                  await WatchlistManager.removeFromWatchlist(item['id']);
                                } else {
                                  await WatchlistManager.addToWatchlist(item);
                                }
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // 🔧 Helper widget for label + value
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label $value',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  // ⭐ Helper widget for row with icon and text (e.g., rating)
  Widget _buildDetailRowWithIcon(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
