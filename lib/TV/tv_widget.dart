import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart'; 
import 'package:streaming_app/widgets/detail_page.dart';
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
    loadTVShows(); // Load the list of movies/shows
  }

 void loadTVShows() async {
  try {
    final shows = await widget.fetchTVShows();
    if (!mounted) return; // Avoid setState if the widget was disposed
    setState(() {
      TVShows = shows;
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return; // Also check on error
    setState(() {
      isLoading = false;
    });
  }
}


  // Scroll left by 1000px
  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 1000,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  // Scroll right by 1000px
  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 1000,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // Movie/TV cards in horizontal list
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              // Horizontal scrollable list
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: TVShows.length,
                itemBuilder: (context, index) {
                  final show = TVShows[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

              // Scroll Left Button
              Positioned(
                left: 0,
                top: 90,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  onPressed: _scrollLeft,
                ),
              ),

              // Scroll Right Button
              Positioned(
                right: 0,
                top: 90,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.white,
                  style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  onPressed: _scrollRight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}