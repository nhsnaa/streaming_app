import 'package:flutter/material.dart';
import '../services/tmdb_service1.dart';
import 'movie_widget.dart';

class NowPlayingMovies extends StatelessWidget {
  final TMDBService _tmdbService = TMDBService();

  @override
  Widget build(BuildContext context) {
    return MovieWidget(
      title: 'Now Playing',
      fetchMovieShows: _tmdbService.fetchNowPlayingMovies,
    );
  }
}