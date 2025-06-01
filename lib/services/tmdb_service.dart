import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_key.dart'; 

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<dynamic>> fetchTrendingMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/trending/movie/week?api_key=$tmdbApiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  Future<List<dynamic>> fetchNowPlayingMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/now_playing?api_key=$tmdbApiKey'));
    return jsonDecode(response.body)['results'];
  }

  Future<List<dynamic>> fetchUpcomingMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/upcoming?api_key=$tmdbApiKey'));
    return jsonDecode(response.body)['results'];
  }

  Future<List<dynamic>> fetchTopRatedMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/top_rated?api_key=$tmdbApiKey'));
    return jsonDecode(response.body)['results'];
  }

  Future<List<dynamic>> fetchRecommendedMovies(int movieId) async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/recommendations?api_key=$tmdbApiKey'));
    return jsonDecode(response.body)['results'];
  }

Future<List<dynamic>> searchMovies(String query) async {
  final url = 'https://api.themoviedb.org/3/search/movie?api_key=073ec7277ad93376c6b8976095d16bdd&query=${Uri.encodeComponent(query)}'
;

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['results'];
  } else {
    throw Exception('Failed to search movies');
  }
}

}

