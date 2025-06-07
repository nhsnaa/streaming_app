import 'package:flutter/material.dart';
import '../services/favorites_manager.dart';

/// This widget shows a heart icon (filled or border) depending on favorite status.
/// It allows users to toggle an item as a favorite.
class FavoriteIcon extends StatefulWidget {
  final dynamic item;

  const FavoriteIcon({super.key, required this.item});

  @override
  State<FavoriteIcon> createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
  @override
  Widget build(BuildContext context) {
    // Check if the current item is in the favorites list
    final isFav = FavoritesManager.isFavorite(widget.item);

    return IconButton(
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border, // Filled or border heart
        color: isFav ? Colors.red : Colors.white,
      ),
      onPressed: () {
        // When clicked, toggle favorite status and update the UI
        setState(() {
          FavoritesManager.toggleFavorite(widget.item);
        });

        // Optional: show a snackbar to confirm action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFav ? 'Removed from Favorites' : 'Added to Favorites',
            ),
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
    );
  }
}

