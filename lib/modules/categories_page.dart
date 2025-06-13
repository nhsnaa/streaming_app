import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/hover_movie_card.dart';
import 'package:streaming_app/services/tmdb_service1.dart';
import 'package:streaming_app/widgets/detail_page.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';
import 'package:streaming_app/search_results.dart';
import 'package:google_fonts/google_fonts.dart';

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
      final fetched = selectedType == 'Movies'
          ? await TMDBService().fetchMoviesByGenre(genreId)
          : await TMDBService().fetchTVByGenre(genreId);

      setState(() {
        items = fetched.where((m) => m['poster_path'] != null).toList();
      });
    } catch (e) {
      print('Error loading content: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final genres = selectedType == 'Movies' ? movieGenres : tvGenres;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 39, 38, 38),
      appBar: AppBar(
        automaticallyImplyLeading: false, // This hides the back button
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
              const SizedBox(height: 12), //jarak utk genre phase
              // Genre chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12), //box of the genre grouped
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: genres.map((genre) {
                      final isSelected = selectedGenre == genre['name'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGenre = genre['name'];
                              selectedGenreId = genre['id'];
                            });
                            _loadContentByGenre(selectedGenreId);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Colors.blueAccent, Colors.purpleAccent],
                                  )
                                : null,
                            color: isSelected ? null : Colors.grey[850],
                            ),

                            child: Text(
                              genre['name'],
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Grid view of content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160, // Max width of each card
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20, //between card
                    childAspectRatio: 0.6, //space between card in a row
                  ),

                    itemBuilder: (context, index) {
                      final item = items[index];
                      final title = selectedType == 'Movies'
                          ? item['title']
                          : item['name'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HoverMovieCard(
                            item: item,
                            height: 200,
                            width: double.infinity,
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