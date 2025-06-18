import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart';
import 'package:streaming_app/widgets/hover_movie_card.dart';

class TVWidget extends StatefulWidget {
  final String title;
  final Future<List<dynamic>> Function() fetchTVShows;

  const TVWidget({
    super.key,
    required this.title,
    required this.fetchTVShows,
  });

  @override
  State<TVWidget> createState() => _TVWidgetState();
}

class _TVWidgetState extends State<TVWidget> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> TVShows = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTVShows();
  }

  void loadTVShows() async {
    try {
      final shows = await widget.fetchTVShows();
      if (!mounted) return;
      setState(() {
        TVShows = shows;
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
                : TVShows.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No content available.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : SizedBox(
                        height: 270, // Enough height for hover animation
                        child: Stack(
                          clipBehavior: Clip.none, // Allow hover overflow
                          children: [
                            // Horizontal scroll list of TV posters
                            ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              clipBehavior: Clip.none, // Keep hover effects visible
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              itemCount: TVShows.length,
                              itemBuilder: (context, index) {
                                final show = TVShows[index];
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

                            // Left scroll button
                            Positioned(
                              left: 8,
                              top: 80,
                              child: _ScrollButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onTap: _scrollLeft,
                              ),
                            ),

                            // Right scroll button
                            Positioned(
                              right: 8,
                              top: 80,
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

// Reusable circular scroll button widget
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
