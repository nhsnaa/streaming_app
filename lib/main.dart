import 'package:flutter/material.dart';
import 'package:streaming_app/home_page.dart';
import 'package:streaming_app/services/user_data.dart';
import 'package:streaming_app/modules/profile_page.dart';
import 'intro_page.dart';
import 'login_page.dart';
import 'signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserData.loadUsersFromPrefs(); // Load registered users
  await UserData.loadUserFromPrefs();  
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/profile',  
      routes: {
        '/intro': (context) => IntroPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
        ),
      ),
    );
  }
}