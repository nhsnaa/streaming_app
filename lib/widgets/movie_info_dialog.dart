import 'package:flutter/material.dart';
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
    final voteAverage = item['vote_average']?.toString() ?? 'N/A';
    final originalLanguage = item['original_language']?.toUpperCase() ?? 'N/A';

    final List<int> genreIds = List<int>.from(item['genre_ids'] ?? []);
    final List<String> genreNames =
        genreIds.map((id) => genreMap[id] ?? 'Unknown').toList();
    final String genreText = genreNames.join(', ');

    return Dialog(
      backgroundColor: const Color.fromARGB(255, 41, 38, 38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20), //gap between boarder
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: 600,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (posterPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500$posterPath',
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Release: $releaseDate',
                              style: const TextStyle(color: Colors.white70)),
                          Text('Rating: $voteAverage',
                              style: const TextStyle(color: Colors.white70)),
                          Text('Language: $originalLanguage',
                              style: const TextStyle(color: Colors.white70)),
                          Text('Genres: $genreText',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        overview,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
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
                        icon:
                            const Icon(Icons.play_arrow, color: Colors.black),
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
