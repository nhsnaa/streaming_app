import 'package:flutter/material.dart';
import '../services/tmdb_service1.dart';
import 'movie_widget.dart';

class PopularMovies extends StatelessWidget {
  final TMDBService _tmdbService = TMDBService();

  @override
  Widget build(BuildContext context) {
    return MovieWidget(
      title: 'Popular',
      fetchMovieShows: _tmdbService.fetchPopularMovies,
    );
  }
}
