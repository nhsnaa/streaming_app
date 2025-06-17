import 'package:flutter/material.dart';
import 'package:streaming_app/services/favorites_manager.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';
import 'package:streaming_app/widgets/hover_movie_card.dart';

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
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: const Text('Favourites'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
         bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Movies'),
              Tab(text: 'TV Shows'),
            ],
            labelColor: Colors.blueAccent,            // Selected tab text color
            unselectedLabelColor: Colors.white54,    // Unselected tab text color
            indicatorColor: Colors.blueAccent,        // Line under the selected tab
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
            _buildFavoritesSection(_movieFavorites, 'Movies'),
            _buildFavoritesSection(_tvFavorites, 'TV Shows'),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesSection(List<dynamic> items, String title) {
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

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Your $title',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    HoverMovieCard(
                      item: item,
                      width: 160,
                      height: 240,
                      onTap: () async {
                        final shouldRemove = await showDialog<bool>(
                          context: context,
                          builder: (_) => MovieInfoDialog(item: item),
                        );
                        if (shouldRemove == true) {
                          _removeFavorite(item);
                        }
                      },
                    ),
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
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
