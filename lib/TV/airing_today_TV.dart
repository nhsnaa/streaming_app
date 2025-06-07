import 'package:flutter/material.dart';
import '../services/tmdb_service1.dart';
import 'tv_widget.dart';

class AiringTodayTV extends StatelessWidget {
  final TMDBService _tmdbService = TMDBService();

  @override
  Widget build(BuildContext context) {
    return TVWidget(
      title: 'Airing Today',
      fetchTVShows: _tmdbService.fetchAiringTodayTV,
    );
  }
}

