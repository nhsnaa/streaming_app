import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_data.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void resetPassword() async {
    final email = emailController.text.trim();
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    final result = await UserData.resetPassword(email, newPassword, confirmPassword);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        backgroundColor: result == 'Password reset successful.'
            ? Colors.green
            : Colors.redAccent,
        duration: Duration(seconds: 3),
      ),
    );

    if (result == 'Password reset successful.') {
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    }
  }

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
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_reset_rounded, size: 80, color: Colors.blueAccent),
                        const SizedBox(height: 16),
                        Text(
                          "Reset Password",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your email and set a new password below.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 32),
                        buildTextField("Registered Email", emailController, false),
                        buildTextField("New Password", newPasswordController, true),
                        buildTextField("Confirm New Password", confirmPasswordController, true),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: resetPassword,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: Text(
                            'Reset Password',
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),

            // X (close) button in the top-right corner
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, bool obscure) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(
            obscure ? Icons.lock : Icons.email,
            color: Colors.white,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }
}
