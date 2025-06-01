// A simple class to represent a User
class User {
  final String email;
  final String password;

  User({required this.email, required this.password});

}

class UserData {
  // A static list to simulate a simple user database.
  // Each user is stored as a map with 'email' and 'password' keys.
  static final List<Map<String, String>> _users = [];

  /// Registers a new user.
  /// Returns true if registration is successful.
  /// Returns false if the email is already registered.
  static bool register(String email, String password) {
    // Check if the email already exists in the "database"
    if (_users.any((user) => user['email'] == email)) {
      return false; // Email already registered
    }

    // Add the new user to the list
    _users.add({'email': email, 'password': password});
    return true; // Registration successful
  }

  /// Logs in a user by checking if the credentials match any registered user.
  /// Returns true if login is successful, false otherwise.
  static bool login(String email, String password) {
    // Check if a user with matching email and password exists
    return _users.any((user) =>
        user['email'] == email && user['password'] == password);
  }
}


