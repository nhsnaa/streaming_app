import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';
import 'package:streaming_app/widgets/hover_movie_card.dart';

class MovieWidget extends StatefulWidget {
  final String title;
  final Future<List<dynamic>> Function() fetchMovieShows;

  const MovieWidget({
    super.key,
    required this.title,
    required this.fetchMovieShows,
  });

  @override
  State<MovieWidget> createState() => _MovieWidgetState();
}

class _MovieWidgetState extends State<MovieWidget> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> movieShows = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMovieShows();
  }

  void loadMovieShows() async {
    try {
      final shows = await widget.fetchMovieShows();
      if (!mounted) return;
      setState(() {
        movieShows = shows;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 800,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 800,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0), // Space between vertical sections
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Main content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : movieShows.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No content available.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : SizedBox(
              height: 270,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none, // Must be none to allow hover scale/translate
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    itemCount: movieShows.length,
                    itemBuilder: (context, index) {
                      final show = movieShows[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: HoverMovieCard(
                          item: show,
                          height: 200,
                          width: 140,
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (_) => MovieInfoDialog(item: show),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 8,
                    top: 100, // 🔧 Adjusted scroll button to vertically center better
                    child: _ScrollButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: _scrollLeft,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 100,
                    child: _ScrollButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      onTap: _scrollRight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Scroll button widget with elevation and circular shape
class _ScrollButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScrollButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
