import 'package:flutter/material.dart';
import '../services/tmdb_service1.dart';
import 'package:streaming_app/widgets/detail_page.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart'; 


class SearchResults extends StatefulWidget {
  final String query;
  SearchResults({Key? key, required this.query}) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  final TMDBService _tmdbService = TMDBService();
  String contentType = 'Movies'; // Default to Movies
  Future<List<dynamic>>? _futureResults;



  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  @override
  void didUpdateWidget(covariant SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _fetchResults();
    }
  }

  void _fetchResults() {
    setState(() {
      if (contentType == 'Movies') {
        _futureResults = _tmdbService.searchMovies(widget.query);
      } else {
        _futureResults = _tmdbService.searchTVShows(widget.query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle buttons for Movies / TV Shows
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['Movies', 'TV Shows'].map((type) {
              final isSelected = contentType == type;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextButton(
                  onPressed: () {
                    if (contentType != type) {
                      setState(() {
                        contentType = type;
                        _fetchResults();
                      });
                    }
                  },
                  child: Text(
                    type,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Results List
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _futureResults,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No results found"));
              }

              final results = snapshot.data!;
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];

                  // Titles and dates differ for movies vs TV shows
                  final title = contentType == 'Movies' 
                      ? item['title'] ?? 'No title' 
                      : item['name'] ?? 'No name';

                  final date = contentType == 'Movies'
                      ? item['release_date'] ?? 'No date'
                      : item['first_air_date'] ?? 'No date';

                 return ListTile(
                    leading: item['poster_path'] != null
                        ? Image.network(
                            'https://image.tmdb.org/t/p/w92${item['poster_path']}',
                            fit: BoxFit.cover,
                          )
                        : const SizedBox.shrink(),

                    // Customize title text
                    title: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,       
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Customize subtitle text
                    subtitle: Text(
                      date,
                      style: const TextStyle(
                        color: Colors.grey,  
                      ),
                    ),

                    onTap: () async {
                      final shouldPlay = await showDialog<bool>(
                        context: context,
                        builder: (_) => MovieInfoDialog(item: item),
                      );
                      if (shouldPlay == true && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailPage(item: item)),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


