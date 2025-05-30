import 'package:flutter/material.dart';
import 'services/tmdb_service.dart';
import 'modules/categories_page.dart';
import 'modules/favourites_page.dart';
import 'modules/inbox_page.dart';
import 'modules/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Index of the selected BottomNavigationBar tab
  int _selectedIndex = 0;

  // TMDB service instance
  final TMDBService _tmdbService = TMDBService();

  // Movie data
  List<dynamic> movies = [];
  List<dynamic> filteredMovies = [];

  // Loading state and search state
  bool isLoading = true;
  bool isSearching = false;
  String searchQuery = '';

  // Fetch trending movies from TMDB on widget initialization
  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  // Load trending movies from TMDB API
  void loadMovies() async {
    try {
      final fetchedMovies = await _tmdbService.fetchTrendingMovies();
      setState(() {
        movies = fetchedMovies;
        filteredMovies = fetchedMovies;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update the search result based on user input
  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredMovies = movies
          .where((movie) =>
              (movie['title'] ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  // Handle tab tap and switch index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Reset search when switching to other tabs
      if (index != 0) {
        isSearching = false;
        searchQuery = '';
        filteredMovies = movies;
      }
    });
  }

  // Return title for AppBar based on selected tab
  String _getAppBarTitle(int index) {
    switch (index) {
      case 1:
        return 'Favourites';
      case 2:
        return 'Inbox';
      case 3:
        return 'Profile';
      default:
        return 'Trending Movies';
    }
  }

  // Return body widget for selected tab
  Widget _getBodyWidget(int index) {
    switch (index) {
      case 1:
        return const FavouritesPage();
      case 2:
        return const InboxPage();
      case 3:
        return const ProfilePage();
      default:
        // This should never be reached since index 0 handled separately
        return const CategoriesPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show search bar only for Categories (index 0)
        title: _selectedIndex == 0
            ? isSearching
                ? TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search movies...',
                      border: InputBorder.none,
                    ),
                    onChanged: updateSearch,
                  )
                : const Text("Trending Movies")
            : Text(_getAppBarTitle(_selectedIndex)),

        // Show search icon only in Categories tab
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: Icon(isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                      if (!isSearching) {
                        searchQuery = '';
                        filteredMovies = movies;
                      }
                    });
                  },
                ),
              ]
            : null,
      ),

      // Show movie list if Categories is selected (index 0)
      // Otherwise, show respective module pages
      body: _selectedIndex == 0
          ? (isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = filteredMovies[index];
                    return ListTile(
                      leading: movie['poster_path'] != null
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.movie),
                      title: Text(movie['title'] ?? 'No title'),
                      subtitle: Text(
                        movie['overview'] ?? 'No overview',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ))
          : _getBodyWidget(_selectedIndex),

      // Bottom Navigation Bar with 4 items
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,           // Current selected index
        onTap: _onItemTapped,                   // Change index when tapped
        selectedItemColor: Colors.blueAccent,   // Color for selected item
        unselectedItemColor: Colors.grey,       // Color for unselected items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}