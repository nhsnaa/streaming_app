import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';
import 'package:streaming_app/widgets/detail_page.dart';
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
    } catch (e) {
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
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (movieShows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No content available.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),

        // Poster Row
        SizedBox(
          height: 240,
          child: Stack(
            children: [
              // Horizontal Scroll List
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: movieShows.length,
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                itemBuilder: (context, index) {
                  final show = movieShows[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: HoverMovieCard(
                      item: show,
                      height: 200,
                      width: 140,
                      onTap: () async {
                        final shouldPlay = await showDialog<bool>(
                          context: context,
                          builder: (_) => MovieInfoDialog(item: show),
                        );

                        if (shouldPlay == true && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(item: show),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),

              // Left scroll button
              Positioned(
                left: 0,
                top: 80,
                child: _ScrollButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: _scrollLeft,
                ),
              ),

              // Right scroll button
              Positioned(
                right: 0,
                top: 80,
                child: _ScrollButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: _scrollRight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom scroll button with better design
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
      color: Colors.black.withOpacity(0.4),
      shape: const CircleBorder(),
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
