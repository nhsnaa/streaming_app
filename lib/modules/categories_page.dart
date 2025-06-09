import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/hover_movie_card.dart';
import 'package:streaming_app/services/tmdb_service1.dart';
import 'package:streaming_app/widgets/detail_page.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart'; // ✅ Import the floating info dialog

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  // ✅ Define genres
  final List<Map<String, dynamic>> movieGenres = [
    {'name': 'Action', 'id': 28},
    {'name': 'Adventure', 'id': 12},
    {'name': 'Animation', 'id': 16},
    {'name': 'Comedy', 'id': 35},
    {'name': 'Drama', 'id': 18},
    {'name': 'Horror', 'id': 27},
    {'name': 'Romance', 'id': 10749},
    {'name': 'Thriller', 'id': 53},
  ];

  final List<Map<String, dynamic>> tvGenres = [
    {'name': 'Action & Adventure', 'id': 10759},
    {'name': 'Animation', 'id': 16},
    {'name': 'Comedy', 'id': 35},
    {'name': 'Crime', 'id': 80},
    {'name': 'Documentary', 'id': 99},
    {'name': 'Drama', 'id': 18},
    {'name': 'Family', 'id': 10751},
    {'name': 'Mystery', 'id': 9648},
  ];

  List<dynamic> items = [];
  bool isLoading = false;
  String selectedType = 'Movies';
  String selectedGenre = 'Action';

  @override
  void initState() {
    super.initState();
    _loadContentByGenre(28); // Load Action movies by default
  }

  // ✅ Load content from TMDB by genre
  Future<void> _loadContentByGenre(int genreId) async {
    setState(() => isLoading = true);

    try {
      if (selectedType == 'Movies') {
        final fetched = await TMDBService().fetchMoviesByGenre(genreId);
        setState(() {
          items = fetched.where((m) => m['poster_path'] != null).toList();
        });
      } else {
        final fetched = await TMDBService().fetchTVByGenre(genreId);
        setState(() {
          items = fetched.where((m) => m['poster_path'] != null).toList();
        });
      }
    } catch (e) {
      print('Error loading content: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final genres = selectedType == 'Movies' ? movieGenres : tvGenres;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ✅ Toggle Movies / TV Shows
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['Movies', 'TV Shows'].map((type) {
                    final isSelected = selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = type;
                            selectedGenre = (type == 'Movies'
                                    ? movieGenres
                                    : tvGenres)[0]['name'];
                            _loadContentByGenre((type == 'Movies'
                                    ? movieGenres
                                    : tvGenres)[0]['id']);
                          });
                        },
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.white70,
                            decoration:
                                isSelected ? TextDecoration.underline : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                // ✅ Genre selector
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: genres.length,
                    itemBuilder: (context, index) {
                      final genre = genres[index];
                      final isSelected = selectedGenre == genre['name'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? Colors.lightBlue
                                : Colors.grey.shade300,
                            foregroundColor:
                                isSelected ? Colors.white : Colors.black,
                          ),
                          onPressed: () {
                            setState(() => selectedGenre = genre['name']);
                            _loadContentByGenre(genre['id']);
                          },
                          child: Text(genre['name']),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Grid of cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 20,
                    children: items.map((item) {
                      final title = selectedType == 'Movies'
                          ? item['title']
                          : item['name'];

                      return SizedBox(
                        width: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HoverMovieCard(
                              item: item, // ✅ Pass full item here
                              height: 200,
                              width: 140,
                              onTap: () async {
                                // ✅ Show floating dialog first
                                final shouldPlay = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => MovieInfoDialog(item: item),
                                );

                                // ✅ If user pressed play, navigate to DetailPage
                                if (shouldPlay == true && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailPage(item: item),
                                    ),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }
}













