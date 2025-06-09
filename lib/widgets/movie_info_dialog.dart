import 'package:flutter/material.dart';
import '../widgets/detail_page.dart';

class MovieInfoDialog extends StatelessWidget {
  final dynamic item;

  const MovieInfoDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item['title'] ?? item['name'] ?? 'No title';
    final overview = item['overview'] ?? 'No overview';
    final posterPath = item['poster_path'];
    final releaseDate = item['release_date'] ?? item['first_air_date'] ?? 'N/A';
    final voteAverage = item['vote_average']?.toString() ?? 'N/A';
    final originalLanguage = item['original_language']?.toUpperCase() ?? 'N/A';
    

    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6, // max 60% screen height
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (posterPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500$posterPath',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Additional info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Release: $releaseDate',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Rating: $voteAverage',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'lang: $originalLanguage',
                      style: const TextStyle(color: Colors.white70),
                    ),
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
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(item: item),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Play Trailer"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
