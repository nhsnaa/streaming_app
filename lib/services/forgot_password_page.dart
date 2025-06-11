import 'package:flutter/material.dart';
import 'user_data.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String message = '';

 void resetPassword() async {
  final email = emailController.text.trim();
  final newPassword = newPasswordController.text;
  final confirmPassword = confirmPasswordController.text;

  final result = await UserData.resetPassword(email, newPassword, confirmPassword);

  // Show Snackbar for feedback
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
    await Future.delayed(Duration(seconds: 1)); // small delay for user to see snackbar
    Navigator.pop(context);
  }
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // black background
      appBar: AppBar(
        title: Text("Forgot Password"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildTextField("Registered Email", emailController, false),
            buildTextField("New Password", newPasswordController, true),
            buildTextField("Confirm New Password", confirmPasswordController, true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Reset Password', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 12),
            if (message.isNotEmpty)
              Text(
                message,
                style: TextStyle(color: Colors.redAccent, fontSize: 14),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, bool obscure) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

