import 'package:flutter/material.dart';
import '../services/favorites_manager.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  @override
  Widget build(BuildContext context) {
    FavoritesManager.sortFavorites();
    final favorites = FavoritesManager.favorites;
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              setState(() {
                FavoritesManager.clearFavorites(); // Clear all favorites
              });
            },
          ),
        ],
      ),
      
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return ListTile(
                  leading: item['poster_path'] != null
                      ? Image.network('https://image.tmdb.org/t/p/w92${item['poster_path']}')
                      : const Icon(Icons.movie, color: Colors.white),
                  title: Text(
                    item['title'] ?? item['name'] ?? 'No Title',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
    );
  }
}
