import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/favourite_icon.dart';
import 'package:streaming_app/widgets/movie_info_dialog.dart'; 

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
          height: 280,
          child: Stack(
            children: [
              // Horizontal scrollable list
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: TVShows.length,
                itemBuilder: (context, index) {
                  final show = TVShows[index];

                  return Container(
                    width: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail with tap to open dialog
                        Stack( 
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Show detail dialog instead of navigating to new screen
                                showDialog(
                                  context: context,
                                  builder: (context) => MovieInfoDialog(item: show),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: show['poster_path'] != null
                                    ? Image.network(
                                        'https://image.tmdb.org/t/p/w185${show['poster_path']}',
                                        height: 200,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 200,
                                        width: 150,
                                        color: Colors.grey,
                                        child: const Icon(Icons.movie, size: 60),
                                      ),
                              ),
                            ),

                            // Heart (favorite) icon
                            Positioned(
                              top: 8,
                              right: 8,
                              child: FavoriteIcon(item: show),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Movie or TV show title
                        Text(
                          show['title'] ?? show['name'] ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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