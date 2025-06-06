import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/hover_movie_card.dart';
import 'package:streaming_app/services/tmdb_service1.dart';
import 'package:streaming_app/widgets/detail_page.dart'; // ✅ Import DetailPage instead of dialog

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  // Movie genres
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

  // TV genres
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
    _loadContentByGenre(28); // Load default "Action" movies on start
  }

  // ✅ Load content (movies or TV) by selected genre
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

                // ✅ Toggle between Movies and TV
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

                // ✅ Genre chips
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

                // ✅ Grid of movie/TV cards
                Padding(
  padding: const EdgeInsets.all(16),
  child: LayoutBuilder(
    builder: (context, constraints) {
      // Responsive column count
      final crossAxisCount = constraints.maxWidth > 800
          ? 5
          : constraints.maxWidth > 600
              ? 4
              : 2;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 0.55,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final title = selectedType == 'Movies'
              ? item['title']
              : item['name'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Hover effect & navigation
              HoverMovieCard(
                imageUrl:
                    'https://image.tmdb.org/t/p/w500${item['poster_path']}',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(item: item),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // ✅ Title with overflow control
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
      );
    },
  ),
)

              ],
            ),
          );
  }
}












