import 'package:flutter/material.dart';
import 'package:streaming_app/services/user_data.dart';
import 'package:streaming_app/modules/watch_later_page.dart'; // ✅ New page

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.white),
            title: const Text('Watch Later', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WatchLaterPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.white),
            title: const Text('History', style: TextStyle(color: Colors.white)),
            onTap: () => _showHistory(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
            onTap: () => _confirmDeleteAccount(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Log Out', style: TextStyle(color: Colors.white)),
            onTap: () async {
              await UserData.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
