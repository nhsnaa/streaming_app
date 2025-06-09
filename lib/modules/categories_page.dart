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
  List<Map<String, dynamic>> movieGenres = [];
  List<Map<String, dynamic>> tvGenres = [];

  List<dynamic> items = [];
  bool isLoading = false;

  String selectedType = 'Movies';
  String selectedGenre = '';
  int selectedGenreId = 0;

  @override
  void initState() {
    super.initState();
    _loadGenresAndContent();
  }

  Future<void> _loadGenresAndContent() async {
    setState(() => isLoading = true);

    try {
      if (selectedType == 'Movies') {
        movieGenres = await TMDBService().fetchMovieGenres();
        if (movieGenres.isNotEmpty) {
          selectedGenre = movieGenres[0]['name'];
          selectedGenreId = movieGenres[0]['id'];
          await _loadContentByGenre(selectedGenreId);
        }
      } else {
        tvGenres = await TMDBService().fetchTVGenres();
        if (tvGenres.isNotEmpty) {
          selectedGenre = tvGenres[0]['name'];
          selectedGenreId = tvGenres[0]['id'];
          await _loadContentByGenre(selectedGenreId);
        }
      }
    } catch (e) {
      print('Error loading genres or content: $e');
    }

    setState(() => isLoading = false);
  }

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

                // Toggle Movies / TV Shows
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
                          });
                          _loadGenresAndContent();
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

                // Genre selector
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
                            setState(() {
                              selectedGenre = genre['name'];
                              selectedGenreId = genre['id'];
                            });
                            _loadContentByGenre(selectedGenreId);
                          },
                          child: Text(genre['name']),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Grid of cards
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
                              item: item,
                              height: 200,
                              width: 140,
                              onTap: () async {
                                final shouldPlay = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => MovieInfoDialog(item: item),
                                );

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














