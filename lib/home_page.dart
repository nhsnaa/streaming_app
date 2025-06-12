import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Importing movie and TV section widgets
import 'package:streaming_app/Movies/now_playing_movies.dart';
import 'package:streaming_app/Movies/popular_movies.dart';
import 'package:streaming_app/Movies/top_rated_movies.dart';
import 'package:streaming_app/Movies/upcoming_movies.dart';
import 'package:streaming_app/TV/airing_today_TV.dart';
import 'package:streaming_app/TV/on_the_air_TV.dart';
import 'package:streaming_app/TV/popular_TV.dart';
import 'package:streaming_app/TV/top_rated_TV.dart';
import 'package:streaming_app/widgets/trending_section.dart';
import 'package:streaming_app/widgets/trending_tv_section.dart';

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
                TrendingSection(),
                NowPlayingMovies(),
                PopularMovies(),
                TopRatedMovies(),
                UpcomingMovies(),
              ] else ...[
                TrendingTVSection(),
                AiringTodayTV(),
                PopularTV(),
                TopRatedTV(),
                OnTheAirTV(),
              ],
            ],
          );
        }
      case 1:
        return const CategoriesPage();
      case 2:
        return const FavouritesPage();
      case 3:
        return const ProfilePage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
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
