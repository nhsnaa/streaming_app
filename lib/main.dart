import 'package:flutter/material.dart';
import 'package:streaming_app/modules/home_page.dart';
import 'package:streaming_app/modules/categories_page.dart';
import 'package:streaming_app/services/user_data.dart';
import 'basic_modules/intro_page.dart';
import 'basic_modules/login_page.dart';
import 'basic_modules/signup_page.dart';

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
      initialRoute: '/intro',  
      routes: {
        '/intro': (context) => IntroPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => HomePage(),
        '/categories': (context) => CategoriesPage(),
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black87,
        appBarTheme: const AppBarTheme(
         backgroundColor: Colors.black,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
        ),
      ),
    );
  }
}