import 'package:flutter/material.dart';
import 'package:streaming_app/services/history_manager.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _allHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];
  String _searchQuery = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await HistoryManager.getHistory();
    setState(() {
      _allHistory = history.reversed.toList();
      _applyFilters();
    });
  }

  void _removeItem(int index) async {
    final removed = _filteredHistory[index];
    final originalIndex = _allHistory.indexOf(removed);
    await HistoryManager.removeFromHistory(originalIndex);
    setState(() {
      _allHistory.removeAt(originalIndex);
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${removed['title'] ?? 'item'}'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            await HistoryManager.addToHistory(removed);
            _loadHistory();
          },
        ),
      ),
    );
  }

  void _clearAll() async {
    if (_allHistory.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Clear All History', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete all watch history?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Confirm', style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryManager.clearHistory();
      setState(() {
        _allHistory.clear();
        _applyFilters();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All history cleared.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _applyFilters() {
    _filteredHistory = _allHistory.where((item) {
      final title = (item['title'] ?? item['name'] ?? '').toString().toLowerCase();
      final matchesSearch = title.contains(_searchQuery.toLowerCase());

      final mediaType = item['media_type'];
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Movie' && mediaType == 'movie') ||
          (_filter == 'TV Show' && mediaType == 'tv');

      return matchesSearch && matchesFilter;
    }).toList();
  }

  String _timeAgo(String? timestamp) {
    if (timestamp == null) return '';
    final watchedTime = DateTime.tryParse(timestamp);
    if (watchedTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(watchedTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return 'Watched ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Watched ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inDays < 7) return 'Watched ${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';

    return 'Watched on ${watchedTime.day}/${watchedTime.month}/${watchedTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('History'),
        actions: [
          // 🔍 Search field on right
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _applyFilters();
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _filteredHistory.isNotEmpty ? _clearAll : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              spacing: 8,
              children: ['All', 'Movie', 'TV Show'].map((label) {
                return ChoiceChip(
                  label: Text(label),
                  selected: _filter == label,
                  labelStyle: TextStyle(
                    color: _filter == label ? Colors.black : Colors.white,
                  ),
                  selectedColor: Colors.blueAccent,
                  backgroundColor: Colors.grey.shade800,
                  onSelected: (_) {
                    setState(() {
                      _filter = label;
                      _applyFilters();
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _filteredHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No watch history yet.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Watching'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredHistory.length,
                    itemBuilder: (context, index) {
                      final item = _filteredHistory[index];
                      final title = item['title'] ?? item['name'] ?? 'Unknown';
                      final rawMediaType = item['media_type'] ?? 'movie';
                      final mediaType = rawMediaType == 'tv' ? 'TV Show' : 'Movie';
                      final posterPath = item['poster_path'];
                      final timestamp = item['timestamp'];

                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: posterPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/w154$posterPath',
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.image_not_supported, size: 50, color: Colors.white54),
                          title: Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mediaType,
                                style: const TextStyle(fontSize: 12, color: Colors.white60),
                              ),
                              if (timestamp != null)
                                Text(
                                  _timeAgo(timestamp),
                                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white),
                            onPressed: () => _removeItem(index),
                          ),
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (_) => MovieInfoDialog(item: item),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
