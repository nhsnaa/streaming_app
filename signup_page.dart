import 'package:flutter/material.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'services/user_data.dart';


class SignupPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              _formFields(),
              _signupButton(context),
              const Center(child: Text("Or")),
              _googleButton(),
              _loginRedirect(context),
            ],
          ),
        ),
      ),
    );
  }

  // Header text
  Widget _header() {
    return Column(
      children: [
        const SizedBox(height: 60.0),
        Text(
          "Sign up",
          style: GoogleFonts.akshar(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "Create your account",
          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
        ),
      ],
    );
  }

  // Input fields for email, password, confirm password
  Widget _formFields() {
    return Column(
      children: [
        const SizedBox(height: 20),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: true,
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
        ),
        const SizedBox(height: 20),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Confirm Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.purple.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
        ),
      ],
    );
  }

  // Signup button with named route navigation to main page
Widget _signupButton(BuildContext context) {
  return ElevatedButton(
    onPressed: () {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final success = UserData.register(email, password);

      final message = success ? "Account created!" : "Email already exists.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    },
    style: ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: Colors.purple,
    ),
    child: Text(
      "Sign up",
      style: GoogleFonts.akshar(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}


  // Google sign-in button (no navigation here yet)
  Widget _googleButton() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.purple),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          // TODO: Implement Google sign-in logic
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 30.0,
              width: 30.0,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_signup/google.png'),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 18),
            const Text(
              "Sign In with Google",
              style: TextStyle(fontSize: 16, color: Colors.purple),
            ),
          ],
        ),
      ),
    );
  }

  // Redirect to Login page
  Widget _loginRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            "Login",
            style: TextStyle(color: Colors.purple),
          ),
        ),
      ],
    );
  }
}
