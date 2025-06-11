import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static List<Map<String, String>> _registeredUsers = [];
  static String? _loggedInUser;

  // Public getter for registered users (read-only)
  static List<Map<String, String>> get registeredUsers => _registeredUsers;

  // Load registered users from SharedPreferences
  static Future<void> loadUsersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userListJson = prefs.getStringList('users') ?? [];
    _registeredUsers = userListJson
        .map((u) => Map<String, String>.from(jsonDecode(u)))
        .toList();
    print("Loaded users: $_registeredUsers");
  }

  // Save registered users to SharedPreferences
  static Future<void> saveUsersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userListJson = _registeredUsers.map((u) => jsonEncode(u)).toList();
    await prefs.setStringList('users', userListJson);
    print('✅ Saved users: $userListJson'); 
  }

  // Load logged-in user from SharedPreferences
  static Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedInUser = prefs.getString('loggedInUser');
    print("Logged in user: $_loggedInUser");
  }

  // Save logged-in user to SharedPreferences
  static Future<void> saveUserToPrefs(String email) async {
    final prefs = await SharedPreferences.getInstance();
    _loggedInUser = email;
    await prefs.setString('loggedInUser', email);
    print('✅ Saved loggedInUser: $_loggedInUser'); 
  }

  // Register a new user
  static Future<String> register(
      String email, String password, String confirmPassword) async {
    // Load latest data from SharedPreferences
    await loadUsersFromPrefs();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return 'All fields are required.';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    final exists = _registeredUsers.any((user) => user['email'] == email);
    if (exists) {
      return 'Email already registered.';
    }

    _registeredUsers.add({'email': email, 'password': password});
    await saveUsersToPrefs();
    return 'Registration successful.';
  }

  // Log in a user
  static Future<bool> login(String email, String password) async {
    // Load latest data from SharedPreferences
    await loadUsersFromPrefs();

    final exists = _registeredUsers.any(
        (user) => user['email'] == email && user['password'] == password);

    if (exists) {
      await saveUserToPrefs(email);
      return true;
    }

    return false;
  }

  // Get the current logged-in user
  static String? get loggedInUser => _loggedInUser;

  // Log out
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUser');
    _loggedInUser = null;
  }

  // Get the currently logged-in user's full data
  static Map<String, String>? getCurrentUser() {
    if (_loggedInUser == null) return null;
    return _registeredUsers.firstWhere(
      (user) => user['email'] == _loggedInUser,
      orElse: () => {},
    );
  }

  // Update the current logged-in user's data
  static Future<void> updateCurrentUser(Map<String, String> updatedUser) async {
    if (_loggedInUser == null) return;

    // Find index of the current user
    final index = _registeredUsers.indexWhere((u) => u['email'] == _loggedInUser);
    if (index != -1) {
      _registeredUsers[index] = updatedUser;
      await saveUsersToPrefs();
    }
  }

  // Delete the current logged-in user
  static Future<void> deleteCurrentUser() async {
    if (_loggedInUser == null) return;

    _registeredUsers.removeWhere((u) => u['email'] == _loggedInUser);
    await saveUsersToPrefs();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUser');
    _loggedInUser = null;
  }


  // Reset password for a user
static Future<String> resetPassword(String email, String newPassword, String confirmPassword) async {
  await loadUsersFromPrefs();

  if (email.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
    return 'All fields are required.';
  }

  if (newPassword != confirmPassword) {
    return 'Passwords do not match.';
  }

  final index = _registeredUsers.indexWhere((user) => user['email'] == email);
  if (index == -1) {
    return 'Email not found.';
  }

  _registeredUsers[index]['password'] = newPassword;
  await saveUsersToPrefs();
  return 'Password reset successful.';
}


}







