import 'package:flutter/material.dart';
import 'movie_widget.dart';

class MovieType extends StatelessWidget {
  final String title;
  final Future<List<dynamic>> Function() fetchMovies;

  const MovieType({
    Key? key,
    required this.title,
    required this.fetchMovies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MovieWidget(
      title: title,
      fetchMovieShows: fetchMovies,
    );
  }
}
