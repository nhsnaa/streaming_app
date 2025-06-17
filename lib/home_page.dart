import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


// Importing movie and TV section widgets
import 'package:streaming_app/Movies/movie_type.dart';
import 'package:streaming_app/TV/tv_type.dart';
import 'package:streaming_app/Movies/trending_movies_section.dart';
import 'package:streaming_app/TV/trending_tv_section.dart';
import '../services/tmdb_service1.dart';

// Importing app modules
import 'modules/categories_page.dart';
import 'modules/favourites_page.dart';
import 'modules/profile_page.dart';
import 'search_results.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool isSearching = false;
  String searchQuery = '';
  String selectedContentType = 'Movies';

  final TMDBService _tmdbService = TMDBService();

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _onItemTapped(int index) {
  if (index == 3) {
    // Show popup when Profile is tapped
    showDialog(
      context: context,
      builder: (_) => const ProfilePage(),
    );
  } else {
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        isSearching = false;
        searchQuery = '';
      }
    });
  }
}


  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
        if (searchQuery.isNotEmpty) {
          return SearchResults(query: searchQuery);
        } else {
          return ListView(
            children: [
                // ✅ New section with banner + trending list
              if (selectedContentType == 'Movies') ...[
                const TrendingPage(), // replaces your previous TrendingSection
                MovieType(
                title: 'Now Playing',
                fetchMovies: _tmdbService.fetchNowPlayingMovies,
               ),
                MovieType(
                title: 'Popular',
                fetchMovies: _tmdbService.fetchPopularMovies,
               ),
                MovieType(
                  title: 'Top rated',
                  fetchMovies: _tmdbService.fetchTopRatedMovies,
               ),
                  MovieType(
                  title: 'Upcoming',
                  fetchMovies: _tmdbService.fetchUpcomingMovies,
                ),

              ] else ...[
                const TrendingTVPage(),
                TVType(
                  title: 'Airing Today',
                  fetchTV: _tmdbService.fetchAiringTodayTV,
                ),
                TVType(
                  title: 'On The Air',
                  fetchTV: _tmdbService.fetchOnTheAirTV,
                ),
                TVType(
                  title: 'Popular',
                  fetchTV: _tmdbService.fetchPopularTV,
                ),
                TVType(
                  title: 'Top Rated',
                  fetchTV: _tmdbService.fetchTopRatedTV,
                ),
              ],
            ],
          );
        }
      case 1:
        return const CategoriesPage();
      case 2:
        return const FavouritePage();
      case 3:
        return const ProfilePage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false, // This hides the back button
              title: isSearching
                  ? TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Title...',
                        border: InputBorder.none,
                      ),
                      onChanged: updateSearch,
                      style: const TextStyle(color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'REELORA',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 36,
                            letterSpacing: 1.5,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [Colors.blueAccent, Colors.purpleAccent],
                              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ToggleButtons(
                          isSelected: ['Movies', 'TV Shows']
                          .map((type) => selectedContentType == type)
                          .toList(),
                          onPressed: (index) {
                           final type = ['Movies', 'TV Shows'][index];
                           setState(() {
                            selectedContentType = type;
                            searchQuery = '';
                            isSearching = false;
                            });
                          },
                          borderColor: Colors.white24,
                          selectedBorderColor: Colors.lightBlue,
                          fillColor: Colors.lightBlue.withOpacity(0.2),
                          selectedColor: Colors.lightBlue,
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(8),
                          constraints: const BoxConstraints(minHeight: 32, minWidth: 80),
                          children: const [
                            Text('Movies'),
                            Text('TV Shows'),
                            ],
                          ),
                       ],
                            /// ✅ ToggleButtons just like in Categories UI
                            
                    ),
              actions: [
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search, 
                  color: Colors.white70),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                      if (!isSearching) searchQuery = '';
                    });
                  },
                ),
              ],
            )
          : null,

      body: _getBodyWidget(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favourites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
