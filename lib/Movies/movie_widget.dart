import 'package:flutter/material.dart';
import 'package:streaming_app/widgets/favourite_icon.dart';
import 'package:streaming_app/widgets/detail_page.dart'; 


class MovieWidget extends StatefulWidget {
  final String title;
  final Future<List<dynamic>> Function() fetchMovieShows;

  const MovieWidget({super.key, required this.title, required this.fetchMovieShows});

  @override
  State<MovieWidget> createState() => _MovieWidgetState();
}

class _MovieWidgetState extends State<MovieWidget> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> MovieShows = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMovieShows();
  }

  void loadMovieShows() async {
    try {
      final shows = await widget.fetchMovieShows();
      setState(() {
        MovieShows = shows;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 1000,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 1000,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
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
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: MovieShows.length,
                itemBuilder: (context, index) {
                  final show = MovieShows[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailPage(
                                        item: show,
                                      ),
                                    ),
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
                            Positioned(
                              top: 8,
                              right: 8,
                              child: FavoriteIcon(item: show), // ❤️ Heart icon button
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          show['title'] ?? 'No Title',
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