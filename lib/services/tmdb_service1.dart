import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api_key.dart'; // Your TMDB API key here

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  // Fetch popular movies (example)
  Future<List<dynamic>> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$tmdbApiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  // Fetch now playing movies
  Future<List<dynamic>> fetchNowPlayingMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/now_playing?api_key=$tmdbApiKey'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load now playing movies');
    }
  }

  // Fetch upcoming movies
  Future<List<dynamic>> fetchUpcomingMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/upcoming?api_key=$tmdbApiKey'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }

  // Fetch top rated movies
  Future<List<dynamic>> fetchTopRatedMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/top_rated?api_key=$tmdbApiKey'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

    //TV list

  Future<List<dynamic>> fetchAiringTodayTV() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tv/airing_today?api_key=$tmdbApiKey'), //popular
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load trending tv');
    }
  }

  Future<List<dynamic>> fetchOnTheAirTV() async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/on_the_air?api_key=$tmdbApiKey')); //On The Air TV
    return jsonDecode(response.body)['results'];
  }

   Future<List<dynamic>> fetchPopularTV() async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/popular?api_key=$tmdbApiKey')); //popular TV
    return jsonDecode(response.body)['results'];  
  }

 Future<List<dynamic>> fetchTopRatedTV() async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/top_rated?api_key=$tmdbApiKey')); //Top Rated TV
    return jsonDecode(response.body)['results'];  
  }


  // Search movies 
  Future<List<dynamic>> searchMovies(String query) async {
    final url = '$_baseUrl/search/movie?api_key=$tmdbApiKey&query=${Uri.encodeComponent(query)}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to search movies');
    }
  }

 //search for tv shows
  Future<List<dynamic>> searchTVShows(String query) async {
  final url = '$_baseUrl/search/tv?api_key=$tmdbApiKey&query=${Uri.encodeComponent(query)}';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['results'];
  } else {
    throw Exception('Failed to search TV shows');
  }
}


  // Fetch movies by genre ID
  Future<List<dynamic>> fetchMoviesByGenre(int genreId) async {
    final url = '$_baseUrl/discover/movie?api_key=$tmdbApiKey&with_genres=$genreId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch movies by genre');
    }
  }

   // Fetch TV by genre ID
 Future<List<dynamic>> fetchTVByGenre(int genreId) async {
  final url = '$_baseUrl/discover/tv?api_key=$tmdbApiKey&with_genres=$genreId';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['results'] as List<dynamic>;
  } else {
    throw Exception('Failed to fetch TV shows by genre');
  }
}



  // *** IMPORTANT ***  
  // Fetch all videos (trailers, teasers, clips, etc.) for a movie by ID
  // Fetch trailer for a movie
  Future<String?> fetchYoutubeTrailer(String movieId) async {
  try {
    final url = '$_baseUrl/movie/$movieId/videos?api_key=$tmdbApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> results = data['results'] ?? [];

      for (var video in results) {
        if (video['type'] == 'Trailer' && video['site'] == 'YouTube') {
          return video['key'];
        }
      }
    } else {
      debugPrint('Failed to fetch movie trailer: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error fetching movie trailer: $e');
  }
  return null;
}


Future<String?> fetchYoutubeTVTrailer(String tvId) async {
  // 1. Try main TV show trailer
  final showUrl = '$_baseUrl/tv/$tvId/videos?api_key=$tmdbApiKey';
  final showResponse = await http.get(Uri.parse(showUrl));

  if (showResponse.statusCode == 200) {
    final data = jsonDecode(showResponse.body);
    final results = data['results'] as List<dynamic>;

    final trailer = results.firstWhere(
      (video) =>
          video['type'] == 'Trailer' &&
          video['site'] == 'YouTube' &&
          video['key'] != null,
      orElse: () => null,
    );

    if (trailer != null) {
      return trailer['key'];
    }
  }

  // 2. Fetch seasons of the TV show
  final detailUrl = '$_baseUrl/tv/$tvId?api_key=$tmdbApiKey';
  final detailResponse = await http.get(Uri.parse(detailUrl));

  if (detailResponse.statusCode == 200) {
    final detailData = jsonDecode(detailResponse.body);
    final seasons = detailData['seasons'] as List<dynamic>;

    for (final season in seasons) {
      final seasonNumber = season['season_number'];

      // 2a. Try season-level trailer
      final seasonUrl = '$_baseUrl/tv/$tvId/season/$seasonNumber/videos?api_key=$tmdbApiKey';
      final seasonResponse = await http.get(Uri.parse(seasonUrl));

      if (seasonResponse.statusCode == 200) {
        final seasonData = jsonDecode(seasonResponse.body);
        final seasonResults = seasonData['results'] as List<dynamic>;

        final seasonTrailer = seasonResults.firstWhere(
          (video) =>
              video['type'] == 'Trailer' &&
              video['site'] == 'YouTube' &&
              video['key'] != null,
          orElse: () => null,
        );

        if (seasonTrailer != null) {
          return seasonTrailer['key'];
        }
      }

      // 2b. Try episode 1 of this season
      final episodeUrl =
          '$_baseUrl/tv/$tvId/season/$seasonNumber/episode/1/videos?api_key=$tmdbApiKey';
      final episodeResponse = await http.get(Uri.parse(episodeUrl));

      if (episodeResponse.statusCode == 200) {
        final episodeData = jsonDecode(episodeResponse.body);
        final episodeResults = episodeData['results'] as List<dynamic>;

        final episodeTrailer = episodeResults.firstWhere(
          (video) =>
              video['type'] == 'Trailer' &&
              video['site'] == 'YouTube' &&
              video['key'] != null,
          orElse: () => null,
        );

        if (episodeTrailer != null) {
          return episodeTrailer['key'];
        }
      }
    }
  }

  // No trailer found
  return null;
}

}

