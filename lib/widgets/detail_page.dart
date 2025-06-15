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
  bool _hasTriedVideo = false;

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

    _hasTriedVideo = true;

    if (key != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: key,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showFullscreenButton: true,
          showControls: true,
        ),
      );
      setState(() => _isVideoReady = true);
    } else {
      setState(() => _isVideoReady = false);
    }
  }

  @override
  void dispose() {
    _controller?.close(); // Properly dispose the player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posterPath = widget.item['poster_path'];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            // Maintain 16:9 aspect ratio
            double videoWidth = maxWidth;
            double videoHeight = videoWidth * 9 / 16;
            if (videoHeight > maxHeight) {
              videoHeight = maxHeight;
              videoWidth = videoHeight * 16 / 9;
            }

            return Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: videoWidth,
                    height: videoHeight,
                    child: _isVideoReady && _controller != null
                        ? YoutubePlayer(controller: _controller!)
                        : (posterPath != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    'https://image.tmdb.org/t/p/w500$posterPath',
                                    fit: BoxFit.cover,
                                  ),
                                  if (_hasTriedVideo && !_isVideoReady)
                                    Container(
                                      color: Colors.black54,
                                      child: const Center(
                                        child: Text(
                                          'No trailer available',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : const Center(
                                child: Text(
                                  'No trailer available',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                  ),
                ),

                // ⬅️ Back Button
                Positioned(
                  top: 10,
                  left: 10,
                  child: ClipOval(
                    child: Material(
                      color: Colors.black45,
                      child: InkWell(
                        splashColor: Colors.white24,
                        onTap: () => Navigator.of(context).pop(), // Just close
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
