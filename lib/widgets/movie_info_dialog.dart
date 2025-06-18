import 'package:flutter/material.dart';
import 'package:streaming_app/services/watchlist_manager.dart';
import 'package:streaming_app/services/favorites_manager.dart';
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
  bool _isExpanded = false;

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

    if (!mounted) return;
    setState(() {
      genreMap = {for (var g in genres) g['id']: g['name']};
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final screenWidth = MediaQuery.of(context).size.width;

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

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 41, 38, 38),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Poster
                    if (posterPath != null)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500$posterPath',
                            width: screenWidth * 0.6,
                            fit: BoxFit.cover,
                          ),
                        ),
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

                    const SizedBox(height: 12),

                    _buildDetailRow('Release Date:', releaseDate),
                    _buildDetailRowWithIcon(Icons.star, '$voteAverage/10'),
                    _buildDetailRow('Language:', originalLanguage),
                    _buildDetailRow('Genres:', genreText),

                    const SizedBox(height: 14),

                    const Text(
                      'Overview:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      overview,
                      maxLines: _isExpanded ? null : 4,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white70, height: 1.5),
                    ),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? 'Show less ▲' : 'Read more ▼',
                        style:
                            const TextStyle(color: Colors.lightBlueAccent),
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        minimumSize: const Size(120, 36),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(item: item),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow,
                          color: Colors.black, size: 20),
                      label: const Text("Play Trailer",
                          style: TextStyle(color: Colors.black)),
                    ),

                    const SizedBox(height: 20),

                    // Bookmark & Favorite Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FutureBuilder<bool>(
                          future: WatchlistManager.isInWatchlist(item['id']),
                          builder: (context, snapshot) {
                            final isSaved = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark_added
                                    : Icons.bookmark_add_outlined,
                                color: Colors.redAccent,
                                size: 24,
                              ),
                              onPressed: () async {
                                if (isSaved) {
                                  await WatchlistManager.removeFromWatchlist(item['id']);
                                } else {
                                  await WatchlistManager.addToWatchlist(item);
                                }
                                setState(() {});
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        FutureBuilder<bool>(
                          future: FavoritesManager.isInFavorites(item['id']),
                          builder: (context, snapshot) {
                            final isFavorite = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.pinkAccent,
                                size: 24,
                              ),
                              onPressed: () async {
                                if (isFavorite) {
                                  await FavoritesManager.removeFromFavorites(item['id']);
                                } else {
                                  await FavoritesManager.addToFavorites(item);
                                }
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label $value',
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildDetailRowWithIcon(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
