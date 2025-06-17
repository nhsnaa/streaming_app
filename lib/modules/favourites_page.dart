import 'package:flutter/material.dart';
import 'package:streaming_app/services/favorites_manager.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _movieFavorites = [];
  List<dynamic> _tvFavorites = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final allFavorites = await FavoritesManager.getAllFavorites();
    setState(() {
      _movieFavorites =
          allFavorites.where((item) => item['title'] != null).toList();
      _tvFavorites =
          allFavorites.where((item) => item['name'] != null).toList();
    });
  }

  Future<void> _removeFavorite(dynamic item) async {
    await FavoritesManager.removeFromFavorites(item['id']);
    await _loadFavorites();
  }

  Future<void> _clearFavorites(List<dynamic> items) async {
    for (var item in items) {
      await FavoritesManager.removeFromFavorites(item['id']);
    }
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Favourites'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Movies'), Tab(text: 'TV Shows')],
          ),
          actions: [
            if (_movieFavorites.isNotEmpty || _tvFavorites.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_forever),
                tooltip: 'Clear All',
                onPressed: () {
                  final currentTab = _tabController.index;
                  if (currentTab == 0 && _movieFavorites.isNotEmpty) {
                    _clearFavorites(_movieFavorites);
                  } else if (currentTab == 1 && _tvFavorites.isNotEmpty) {
                    _clearFavorites(_tvFavorites);
                  }
                },
              ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGrid(_movieFavorites),
            _buildGrid(_tvFavorites),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'No favourites here yet.\nStart exploring and add some!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          final posterPath = item['poster_path'];
          final title = item['title'] ?? item['name'] ?? 'No title';

          return GestureDetector(
            onTap: () async {
              final shouldRemove = await showDialog<bool>(
                context: context,
                builder: (_) => MovieInfoDialog(item: item),
              );

              if (shouldRemove == true) {
                _removeFavorite(item);
              }
            },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Poster image
                  posterPath != null
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w500$posterPath',
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.white54,
                              size: 50,
                            ),
                          ),
                        ),

                  // ❤️ Favorite icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeFavorite(item),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                    ),
                  ),

                  // Title overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
