import 'package:flutter/material.dart';
import '../services/watchlist_manager.dart';

class WatchLaterPage extends StatelessWidget {
  const WatchLaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Watch Later'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: WatchlistManager.getWatchlist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No items saved for later.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return ListTile(
                leading: item['poster_path'] != null
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w92${item['poster_path']}',
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(width: 50, child: Icon(Icons.movie, color: Colors.white)),
                title: Text(
                  item['title'] ?? item['name'] ?? 'No title',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
