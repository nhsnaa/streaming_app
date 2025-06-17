import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String _key = 'favorites';

  static Future<List<String>> _getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> addToFavorites(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await _getFavorites();
    favorites.add(jsonEncode(item));
    await prefs.setStringList(_key, favorites);
  }

  static Future<void> removeFromFavorites(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await _getFavorites();
    favorites.removeWhere((item) => jsonDecode(item)['id'] == id);
    await prefs.setStringList(_key, favorites);
  }

  static Future<bool> isInFavorites(int id) async {
    final favorites = await _getFavorites();
    return favorites.any((item) => jsonDecode(item)['id'] == id);
  }

  static Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final favorites = await _getFavorites();
    return favorites
        .map((item) => jsonDecode(item))
        .cast<Map<String, dynamic>>()
        .toList();
  }
}
