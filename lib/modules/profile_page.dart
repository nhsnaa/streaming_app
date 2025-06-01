import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/login_signup/profile.jpg'),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            const Text(
              "Alexand",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            // Email
            const Text(
              "Alexand@example.com",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Details
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Username"),
              subtitle: Text("Alexnad123"),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone"),
              subtitle: Text("+1 234 567 890"),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text("Location"),
              subtitle: Text("Kuala Lumpur, Malaysia"),
            ),

            const Spacer(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Add logout logic if needed
                  Navigator.pop(context);
                },
                icon: Icon(Icons.logout),
                label: Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
