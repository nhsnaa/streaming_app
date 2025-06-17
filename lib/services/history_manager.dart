import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryManager {
  static const String _key = 'watch_history'; // ✅ Consistent key

  /// ✅ Add item to history (prevent duplicates and update timestamp)
  static Future<void> addToHistory(Map<String, dynamic> newItem) async {
    final prefs = await SharedPreferences.getInstance();
    final historyData = prefs.getStringList(_key) ?? [];

    final itemId = newItem['id'];
    final mediaType = newItem['media_type'];
    final newTimestamp = DateTime.now().toIso8601String();

    // Remove existing duplicate
    final updatedList = historyData
        .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
        .where((item) => item['id'] != itemId || item['media_type'] != mediaType)
        .toList();

    // Add new item with current timestamp
    newItem['timestamp'] = newTimestamp;
    updatedList.add(newItem);

    // Save updated list
    final encodedList = updatedList.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(_key, encodedList);
  }

  /// ✅ Get full watch history
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];

    return history.map((e) {
      final item = jsonDecode(e) as Map<String, dynamic>;

      // Infer media_type if missing
      if (!item.containsKey('media_type') || item['media_type'] == null) {
        item['media_type'] =
            item.containsKey('name') && !item.containsKey('title') ? 'tv' : 'movie';
      }

      return item;
    }).toList();
  }

  /// ✅ Remove a single item at a given index
  static Future<void> removeFromHistory(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      await prefs.setStringList(_key, history);
    }
  }

  /// ✅ Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// ✅ Get recent watch history (e.g., for previews or carousels)
  static Future<List<Map<String, dynamic>>> getRecentHistory({int limit = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];

    return history
        .take(limit)
        .map((e) {
          final item = jsonDecode(e) as Map<String, dynamic>;
          if (!item.containsKey('media_type') || item['media_type'] == null) {
            item['media_type'] =
                item.containsKey('name') && !item.containsKey('title') ? 'tv' : 'movie';
          }
          return item;
        }).toList();
  }
}
