import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/user_data.dart';

class SignupPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Create Account",
                      style: GoogleFonts.openSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email
                    _buildTextField(
                      controller: emailController,
                      icon: Icons.email,
                      hint: 'Email',
                    ),

                    const SizedBox(height: 16),

                    // Password
                    _buildTextField(
                      controller: passwordController,
                      icon: Icons.lock,
                      hint: 'Password',
                      isObscure: true,
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password
                    _buildTextField(
                      controller: confirmPasswordController,
                      icon: Icons.lock_outline,
                      hint: 'Confirm Password',
                      isObscure: true,
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();
                        final confirm = confirmPasswordController.text.trim();

                        if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all fields')),
                          );
                          return;
                        }

                        final result = await UserData.register(email, password, confirm);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );

                        if (result == 'Registration successful.') {
                          emailController.clear();
                          passwordController.clear();
                          confirmPasswordController.clear();
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2073EF),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?", style: TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                          child: const Text("Login", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
