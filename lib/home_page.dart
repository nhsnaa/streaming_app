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
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        isSearching = false;
        searchQuery = '';
      }
    });
  }

  Widget _getBodyWidget(int index) {
    switch (index) {
      case 0:
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
        return const ProfilePage();
    
      default:
        return const Center(child: Text('Page not found'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ AppBar only for index 0 (Home)
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.black,
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
                                    decoration: isSelected ? TextDecoration.underline : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      ],
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
          : null, // ❌ No AppBar for other pages

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





