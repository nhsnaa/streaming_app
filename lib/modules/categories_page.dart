import 'package:flutter/material.dart';
import 'package:streaming_app/services/tmdb_service1.dart';
import 'package:streaming_app/widgets/hover_movie_card.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';
import 'package:streaming_app/search_results.dart';

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
  bool isSearching = false;

  String selectedType = 'Movies';
  String selectedGenre = '';
  int selectedGenreId = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGenresAndContent();
  }

  // Load genres and initial content based on selected type (Movies or TV)
  Future<void> _loadGenresAndContent() async {
  if (mounted) setState(() => isLoading = true);

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

  if (mounted) setState(() => isLoading = false);
}

  // Load movie/TV content by genre
  Future<void> _loadContentByGenre(int genreId) async {
  if (mounted) setState(() => isLoading = true);

  try {
    final fetched = selectedType == 'Movies'
        ? await TMDBService().fetchMoviesByGenre(genreId)
        : await TMDBService().fetchTVByGenre(genreId);

    if (mounted) {
      setState(() {
        items = fetched.where((m) => m['poster_path'] != null).toList();
      });
    }
  } catch (e) {
    print('Error loading content: $e');
  }

  if (mounted) setState(() => isLoading = false);
}


  // Show a bottom sheet to pick genre (Netflix-style)
  void _showGenrePicker(BuildContext context) {
    final genres = selectedType == 'Movies' ? movieGenres : tvGenres;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 39, 38, 38),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: genres.map((genre) {
            final isSelected = genre['name'] == selectedGenre;

            return ListTile(
              title: Text(
                genre['name'],
                style: TextStyle(
                  color: isSelected ? Colors.lightBlueAccent : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // close bottom sheet
                setState(() {
                  selectedGenre = genre['name'];
                  selectedGenreId = genre['id'];
                });
                _loadContentByGenre(selectedGenreId);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 38, 38),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: isSearching
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Title...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  ToggleButtons(
                    isSelected: ['Movies', 'TV Shows']
                        .map((type) => selectedType == type)
                        .toList(),
                    onPressed: (index) {
                      final type = ['Movies', 'TV Shows'][index];
                      setState(() {
                        selectedType = type;
                        searchQuery = '';
                        isSearching = false;
                      });
                      _loadGenresAndContent();
                    },
                    borderColor: Colors.white24,
                    selectedBorderColor: Colors.lightBlue,
                    fillColor: Colors.lightBlue.withOpacity(0.2),
                    selectedColor: Colors.lightBlue,
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                    constraints: const BoxConstraints(minHeight: 32, minWidth: 80),
                    children: const [Text('Movies'), Text('TV Shows')],
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchQuery.isNotEmpty
              ? SearchResults(query: searchQuery)
              : Column(
                  children: [
                    const SizedBox(height: 12),

                    // Genre selection button (tap to choose genre)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _showGenrePicker(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedGenre.isEmpty ? 'Select Genre' : selectedGenre,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Grid of movie/TV posters
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.builder(
                          itemCount: items.length,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 160,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.6,
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final title = selectedType == 'Movies' ? item['title'] : item['name'];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HoverMovieCard(
                                  item: item,
                                  height: 200,
                                  width: double.infinity,
                                  onTap: () async {
                                      showDialog(
                                      context: context,
                                      builder: (_) => MovieInfoDialog(item: item),
                                    );
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
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
