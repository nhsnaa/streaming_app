import 'package:flutter/material.dart';
import 'package:streaming_app/Movies/now_playing_movies.dart';
import 'package:streaming_app/Movies/top_rated_movies.dart';
import 'package:streaming_app/Movies/trending_movies.dart';
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
  int _selectedIndex = 0;
  bool isSearching = false;
  String searchQuery = '';

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Reset search when switching tabs
      if (index != 0) {
        isSearching = false;
        searchQuery = '';
      }
    });
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 1:
        return 'Categories';
      case 2:
        return 'Favourites';
      case 3:
        return 'Inbox';
      case 4:
        return 'Profile';
      default:
        return 'Trending Movies';
    }
  }

  Widget _getBodyWidget(int index) {
  switch (index) {
    case 0:
      if (searchQuery.isNotEmpty) {
        return SearchResults(query: searchQuery);
      } else {
        return ListView(
          children: const [
            NowPlayingMovies(),
            TrendingMovies(),
            TopRatedMovies(),
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
        title: _selectedIndex == 0
            ? isSearching
                ? TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search your damn movies...',
                      border: InputBorder.none,
                    ),
                    onChanged: updateSearch,
                  )
                : const Text(
                    "REELORA",
                    style: TextStyle(color: Colors.lightBlueAccent),
                  )
            : Text(_getAppBarTitle(_selectedIndex)),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                      if (!isSearching) {
                        searchQuery = '';
                      }
                    });
                  },
                ),
              ]
            : null,
      ),
      body: _getBodyWidget(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
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
