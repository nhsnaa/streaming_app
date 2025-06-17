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

  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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

  List<dynamic> _filterItems(List<dynamic> items) {
    if (_searchQuery.isEmpty) return items;
    return items.where((item) {
      final title = item['title'] ?? item['name'] ?? '';
      return title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white60,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search favorites...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
              : const Text('Favourites', 
                style: TextStyle(color: Colors.white
                ),
              ),
          actions: [
            if (_isSearching)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
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
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Movies'),
              Tab(text: 'TV Shows'),
            ],
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.blueAccent,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFavoritesSection(_filterItems(_movieFavorites), 'Movies'),
            _buildFavoritesSection(_filterItems(_tvFavorites), 'TV Shows'),
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
          height: 230,
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
                      width: 120,
                      height: 200,
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
