import 'package:flutter/material.dart';
import 'package:streaming_app/home_page.dart';  // Make sure path & project name are correct
import 'package:google_fonts/google_fonts.dart';
import 'services/user_data.dart';

class LoginPage extends StatelessWidget {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  LoginPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(context),           // Displays "Welcome Back" text
            _inputField(context),       // Username and Password fields + Login Button
            _forgotPassword(context),   // Forgot password button
            _signup(context),           // Signup redirect


          ],
        ),
      ),
    );
  }

  // Header text widget
  Widget _header(BuildContext context) {
    return Column(
      children: [
        Text(
          "Welcome Back",
          style: GoogleFonts.akshar(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const Text("Enter your email to login"),
      ],
    );
  }

  // Input form with username, password, and login button
  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            final email = emailController.text.trim();
            final password = passwordController.text.trim();
            final success = UserData.login(email, password);
            if (success) {
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), 
            );
          } else {
             ScaffoldMessenger.of(context).showSnackBar
             (SnackBar(
              content: Text("Wrong email or password", 
              style: TextStyle(
              color: Colors.red,
               ),
              )
             )
            );
          }  
        },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.purple,
          ),
          child: Text(
            "Login",
            style: GoogleFonts.akshar(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Forgot password button
  Widget _forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Add forgot password logic here
      },
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Colors.purple),
      ),
    );
  }

  // Redirect to Signup page
  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Dont have an account? "),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.purple),
          ),
        ),
      ],
    );
  }
}