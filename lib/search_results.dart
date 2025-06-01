import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';

class SearchResults extends StatelessWidget {
  final String query;
  SearchResults({super.key, required this.query});
  
  final TMDBService _tmdbService = TMDBService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _tmdbService.searchMovies(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No results found"));
        }

        final movies = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return ListTile(
              leading: movie['poster_path'] != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                      fit: BoxFit.cover,
                    )
                  : const SizedBox.shrink(),
              title: Text(movie['title'] ?? 'No title'),
              subtitle: Text(movie['release_date'] ?? 'No date'),
            );
          },
        );
      },
    );
  }
}

