// A simple static class to manage favorite items across the app
class FavoritesManager {
  // Internal static list that holds all favorite items (can be movies or TV shows)
  static final List<dynamic> _favorites = [];

  // Public getter to access the list of favorite items
  static List<dynamic> get favorites => _favorites;

  // Toggle function: adds item if not present, removes if already in favorites
  static void toggleFavorite(dynamic item) {
    if (_favorites.contains(item)) {
      _favorites.remove(item); // Remove from favorites if already added
    } else {
      _favorites.add(item); // Add to favorites
    }
  }

  // Checks whether a specific item is already marked as favorite
  static bool isFavorite(dynamic item) {
    return _favorites.contains(item);
  }

  // Removes a specific item from favorites
  static void removeFavorite(dynamic item) {
    _favorites.remove(item);
  }

  // Clears all items from the favorites list
  static void clearFavorites() {
    _favorites.clear();
  }

  // Sorts the favorites list alphabetically by title or name
  static void sortFavorites() {
    _favorites.sort((a, b) {
      final aTitle = a['title'] ?? a['name'] ?? '';
      final bTitle = b['title'] ?? b['name'] ?? '';
      return aTitle.toLowerCase().compareTo(bTitle.toLowerCase());
    });
  }
}


