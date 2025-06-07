import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/hover_movie_card.dart';
import 'package:streaming_app/services/tmdb_service1.dart';
import 'package:streaming_app/widgets/detail_page.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
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
  String selectedGenre = 'Action';

  @override
  void initState() {
    super.initState();
    _loadContentByGenre(28, true); // Default: Action Movies
  }

  Future<void> _loadContentByGenre(int genreId, bool isMovie) async {
    setState(() => isLoading = true);

    try {
      final fetched = isMovie
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
    return DefaultTabController(
      length: 2,
      initialIndex: 0, // Start with Movies
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Categories'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.blue,
            onTap: (index) {
              final isMovie = index == 0;
              final firstGenre =
                  isMovie ? movieGenres[0] : tvGenres[0];

              setState(() {
                selectedGenre = firstGenre['name'];
              });
              _loadContentByGenre(firstGenre['id'], isMovie);
            },
            tabs: const [
              Tab(text: 'Movies'),
              Tab(text: 'TV Shows'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(), // Optional: Lock swiping
          children: [
            _buildContent(isMovie: true),
            _buildContent(isMovie: false),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({required bool isMovie}) {
    final genres = isMovie ? movieGenres : tvGenres;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
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
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            foregroundColor:
                                isSelected ? Colors.white : Colors.black,
                          ),
                          onPressed: () {
                            setState(() => selectedGenre = genre['name']);
                            _loadContentByGenre(genre['id'], isMovie);
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
                      final title = isMovie
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
