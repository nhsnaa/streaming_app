import 'package:flutter/material.dart';
import 'package:streaming_app/services/user_data.dart';
import 'package:streaming_app/widgets/edit_profile_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = UserData.getCurrentUser();
    if (user != null) {
      _email = user['email'] ?? '';
      _usernameController = TextEditingController(text: user['username'] ?? '');
      _phoneController = TextEditingController(text: user['phone'] ?? '');
      _locationController = TextEditingController(text: user['location'] ?? '');
    } else {
      _email = '';
      _usernameController = TextEditingController();
      _phoneController = TextEditingController();
      _locationController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _openEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => EditProfileSheet(
        username: _usernameController.text,
        phone: _phoneController.text,
        location: _locationController.text,
        onSave: (updatedData) {
          setState(() {
            _usernameController.text = updatedData['username']!;
            _phoneController.text = updatedData['phone']!;
            _locationController.text = updatedData['location']!;
            UserData.updateCurrentUser(updatedData);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Add settings functionality here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings clicked")),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/login_signup/profile.jpg'),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _openEditProfile,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildInfoRow('Email', _email),
              _buildInfoRow('Username', _usernameController.text),
              _buildInfoRow('Phone', _phoneController.text),
              _buildInfoRow('Location', _locationController.text),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    UserData.logout();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}





