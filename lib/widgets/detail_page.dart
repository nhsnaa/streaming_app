import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../services/tmdb_service1.dart';

class DetailPage extends StatefulWidget {
  final dynamic item;

  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TMDBService _tmdbService = TMDBService();

  YoutubePlayerController? _controller;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final isMovie = widget.item['title'] != null;
    final id = widget.item['id'].toString();

    final key = isMovie
        ? await _tmdbService.fetchYoutubeTrailer(id)
        : await _tmdbService.fetchYoutubeTVTrailer(id);

    if (key != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: key,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
        ),
      );

      setState(() {
        _isVideoReady = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item['title'] ?? widget.item['name'] ?? 'No title';
    final overview = widget.item['overview'] ?? 'No overview available';
    final posterPath = widget.item['poster_path'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // ✅ Show YouTube player inline if ready, else show poster
          if (_isVideoReady && _controller != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(controller: _controller!),
            )
          else if (posterPath != null)
            Image.network(
              'https://image.tmdb.org/t/p/w500$posterPath',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            )
          else
            const SizedBox(height: 250),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Overview',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              overview,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


