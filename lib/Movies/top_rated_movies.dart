import 'package:flutter/material.dart';
import '../services/tmdb_service1.dart';
import 'movie_widget.dart';

class TopRatedMovies extends StatelessWidget {
  final TMDBService _tmdbService = TMDBService();

  @override
  Widget build(BuildContext context) {
    return MovieWidget(
      title: 'Top rated',
      fetchMovieShows: _tmdbService.fetchTopRatedMovies,
    );
  }
}


