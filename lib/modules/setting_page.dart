import 'package:flutter/material.dart';
import 'package:streaming_app/services/user_data.dart';
import 'package:streaming_app/modules/watch_later_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Show confirmation dialog before deleting account
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Account', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
          ),
          TextButton(
            onPressed: () {
              UserData.deleteCurrentUser();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // Show watch history (placeholder dialog)
  void _showHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Watch History', style: TextStyle(color: Colors.white)),
        content: const Text('This is a placeholder for your watch history.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog before logging out
void _confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('Log Out', style: TextStyle(color: Colors.white)),
      content: const Text(
        'Are you sure you want to log out?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.blueAccent)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // Close the dialog
            await UserData.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
          child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );
}


  // Build a styled section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // Build individual setting tile
  Widget _buildTile(
      {required IconData icon,
      required String title,
      Color iconColor = Colors.white,
      required VoidCallback onTap}) {
    return Card(
      color: const Color(0xFF1C1C1E), // Slightly lighter than black
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ----- PERSONAL SECTION -----
          _buildSectionTitle('PERSONAL'),

          _buildTile(
            icon: Icons.bookmark,
            title: 'Watch Later',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WatchLaterPage()),
              );
            },
          ),
          _buildTile(
            icon: Icons.history,
            title: 'History',
            onTap: () => _showHistory(context),
          ),

          // Divider between sections
          const SizedBox(height: 16),

          // ----- ACCOUNT SECTION -----
          _buildSectionTitle('ACCOUNT'),

          _buildTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            iconColor: Colors.redAccent,
            onTap: () => _confirmDeleteAccount(context),
          ),
          _buildTile(
            icon: Icons.logout,
            title: 'Log Out',
            onTap: () => _confirmLogout(context),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
