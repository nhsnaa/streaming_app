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

// Importing app modules
import 'modules/categories_page.dart';
import 'modules/favourites_page.dart';
import 'modules/inbox_page.dart';
import 'modules/profile_page.dart';
import 'search_results.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Current selected bottom nav index
  bool isSearching = false; // Whether search bar is active
  String searchQuery = ''; // Current search input
  String selectedContentType = 'Movies'; // Either "Movies" or "TV Shows"

  /// Update search text
  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  /// Handle bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        isSearching = false;
        searchQuery = '';
      }
    });
  }

  /// Returns custom AppBar title widget with Google Font
  Widget _getAppBarTitle(int index) {
    String title;
    switch (index) {
      case 1:
        title = 'Categories';
        break;
      case 2:
        title = 'Favourites';
        break;
      case 3:
        title = 'Inbox';
        break;
      case 4:
        title = 'Profile';
        break;
      default:
        title = 'REELORA';
    }

    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 25,
      ),
    );
  }

  /// Returns the body widget based on selected tab
  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
        // Home tab
        if (searchQuery.isNotEmpty) {
          return SearchResults(query: searchQuery);
        } else {
          return ListView(
            children: [
              if (selectedContentType == 'Movies') ...[
                NowPlayingMovies(),
                PopularMovies(),
                TopRatedMovies(),
                UpcomingMovies(),
              ] else ...[
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
        return const InboxPage();
      case 4:
        return const ProfilePage();
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: _selectedIndex == 0
            ? isSearching
                // When search is active
                ? TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Title...',
                      border: InputBorder.none,
                    ),
                    onChanged: updateSearch,
                    style: const TextStyle(color: Colors.white),
                  )
                // When not searching (show title + toggle)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'REELORA',
                        style: GoogleFonts.bebasNeue(
                          color: const Color.fromARGB(255, 32, 115, 239),
                          fontSize: 36,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Toggle between Movies and TV Shows
                      Row(
                        children: ['Movies', 'TV Shows'].map((type) {
                          final isSelected = selectedContentType == type;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedContentType = type;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : Colors.white60,
                                  decoration:
                                      isSelected ? TextDecoration.underline : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  )
            : _getAppBarTitle(_selectedIndex), // Title for other tabs

        // AppBar actions (search icon)
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                      if (!isSearching) searchQuery = '';
                    });
                  },
                ),
              ]
            : null,
      ),

      // Main content
      body: _getBodyWidget(_selectedIndex),

      // Bottom Navigation Bar
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
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}




