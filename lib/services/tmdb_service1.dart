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

//movie genre
Future<List<Map<String, dynamic>>> fetchMovieGenres() async {
  final url = '$_baseUrl/genre/movie/list?api_key=$tmdbApiKey';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['genres']);
  } else {
    throw Exception('Failed to fetch movie genres');
  }
}

//tv genre
Future<List<Map<String, dynamic>>> fetchTVGenres() async {
  final url = '$_baseUrl/genre/tv/list?api_key=$tmdbApiKey';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['genres']);
  } else {
    throw Exception('Failed to fetch TV genres');
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
  Future<String?> _getTrailerFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>;
      final trailer = results.firstWhere(
        (video) =>
            video['type'] == 'Trailer' &&
            video['site'] == 'YouTube' &&
            video['key'] != null,
        orElse: () => null,
      );
      return trailer != null ? trailer['key'] : null;
    }
    return null;
  }

  // 1. Main TV show trailer
  final showTrailer = await _getTrailerFromUrl('$_baseUrl/tv/$tvId/videos?api_key=$tmdbApiKey');
  if (showTrailer != null) return showTrailer;

  // 2. Fetch seasons
  final detailUrl = '$_baseUrl/tv/$tvId?api_key=$tmdbApiKey';
  final detailResponse = await http.get(Uri.parse(detailUrl));

  if (detailResponse.statusCode == 200) {
    final detailData = jsonDecode(detailResponse.body);
    final seasons = detailData['seasons'] as List<dynamic>;

    for (final season in seasons) {
      final seasonNumber = season['season_number'];

      // 2a. Try season trailer
      final seasonTrailer = await _getTrailerFromUrl(
        '$_baseUrl/tv/$tvId/season/$seasonNumber/videos?api_key=$tmdbApiKey',
      );
      if (seasonTrailer != null) return seasonTrailer;

      // 2b. Try episode 1 trailer
      final episodeTrailer = await _getTrailerFromUrl(
        '$_baseUrl/tv/$tvId/season/$seasonNumber/episode/1/videos?api_key=$tmdbApiKey',
      );
      if (episodeTrailer != null) return episodeTrailer;
    }
  }

  // No trailer found
  return null;
}

}

