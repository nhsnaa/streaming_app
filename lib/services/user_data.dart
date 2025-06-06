// A simple class to represent a User
class User {
  final String email;
  final String password;

  User({required this.email, required this.password});
}

class UserData {
  // A static list to simulate a simple user database.
  static final List<Map<String, String>> _users = [];


  static String register(String email, String password, String confirmPassword) {
    // Check if email is already registered
    if (_users.any((user) => user['email'] == email)) {
      return 'Email is already registered.';
    }

    // Check if password and confirm password match
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    // Add the new user
    _users.add({'email': email, 'password': password});
    return 'Registration successful.';
  }


  static bool login(String email, String password) {
    return _users.any((user) =>
        user['email'] == email && user['password'] == password);
  }
}



