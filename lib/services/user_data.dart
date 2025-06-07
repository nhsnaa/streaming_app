class UserData {
  // Simulated user "database" as a list of maps
  static final List<Map<String, String>> _users = [];

  // Currently logged in user's email (null if none logged in)
  static String? _currentUserEmail;

  // Register a new user
  static String register(String email, String password, String confirmPassword) {
    // Check if email already registered
    if (_users.any((user) => user['email'] == email)) {
      return 'Email is already registered.';
    }

    // Check password confirmation
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    // Add new user with some default profile data
    _users.add({
      'email': email,
      'password': password,
      'username': '',
      'phone': '',
      'location': '',
    });
    return 'Registration successful.';
  }

  // Login function, returns true if success and sets current user email
  static bool login(String email, String password) {
    final user = _users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      _currentUserEmail = email; // set current user
      return true;
    }
    return false;
  }

  // Get current logged-in user's info map or null if no user logged in
  static Map<String, String>? getCurrentUser() {
    if (_currentUserEmail == null) return null;

    return _users.firstWhere(
      (user) => user['email'] == _currentUserEmail,
      orElse: () => {},
    );
  }

  // Update current user's profile info with provided newData (e.g. username, phone, location)
  static void updateCurrentUser(Map<String, String> newData) {
    if (_currentUserEmail == null) return;

    final index = _users.indexWhere((user) => user['email'] == _currentUserEmail);
    if (index != -1) {
      _users[index].addAll(newData);
    }
  }

  // Logout current user
  static void logout() {
    _currentUserEmail = null;
  }
}




