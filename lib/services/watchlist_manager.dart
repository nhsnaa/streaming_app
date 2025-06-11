
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistManager {
  static const _key = 'watchlist';

  static Future<List<Map<String, dynamic>>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List decoded = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(decoded);
  }

  static Future<void> addToWatchlist(Map<String, dynamic> item) async {
    final list = await getWatchlist();
    if (!list.any((element) => element['id'] == item['id'])) {
      list.add(item);
      await _save(list);
    }
  }

  static Future<void> removeFromWatchlist(int id) async {
    final list = await getWatchlist();
    list.removeWhere((element) => element['id'] == id);
    await _save(list);
  }

  static Future<bool> isInWatchlist(int id) async {
    final list = await getWatchlist();
    return list.any((element) => element['id'] == id);
  }

  static Future<void> _save(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(list);
    await prefs.setString(_key, jsonString);
  }
}
