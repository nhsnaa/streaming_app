import 'package:flutter/material.dart';
import 'package:streaming_app/services/user_data.dart';
import 'package:streaming_app/widgets/edit_profile_sheet.dart';
import 'package:streaming_app/modules/setting_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;

  String _email = '';
  String _selectedAvatar = 'assets/images/avatars/profile.jpg';

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
      _descriptionController = TextEditingController(text: user['description'] ?? '');
      _selectedAvatar = user['avatar'] ?? _selectedAvatar;
    } else {
      _email = '';
      _usernameController = TextEditingController();
      _phoneController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
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
        description: _descriptionController.text,
        onSave: (updatedData) {
          setState(() {
            _usernameController.text = updatedData['username']!;
            _phoneController.text = updatedData['phone']!;
            _descriptionController.text = updatedData['description']!;
            final current = UserData.getCurrentUser() ?? {};
            UserData.updateCurrentUser({
              ...current,
              ...updatedData,
              'avatar': _selectedAvatar,
            });
          });
        },
      ),
    );
  }

  void _showAvatarPicker() {
    final avatars = [
      'assets/images/avatars/avatars1.png',
      'assets/images/avatars/avatars2.png',
      'assets/images/avatars/avatars3.png',
      'assets/images/avatars/avatars4.png',
      'assets/images/avatars/avatars5.png',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose Your Avatar',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              itemCount: avatars.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatars[index];
                      final current = UserData.getCurrentUser() ?? {};
                      UserData.updateCurrentUser({
                        ...current,
                        'username': _usernameController.text,
                        'phone': _phoneController.text,
                        'description': _descriptionController.text,
                        'email': _email,
                        'avatar': _selectedAvatar,
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(avatars[index]),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedAvatar = 'assets/images/avatars/profile.jpg';
                  UserData.updateCurrentUser({
                    'username': _usernameController.text,
                    'phone': _phoneController.text,
                    'description': _descriptionController.text,
                    'email': _email,
                    'avatar': _selectedAvatar,
                  });
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.restore, color: Colors.white),
              label: const Text('Use Default Picture',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(_selectedAvatar),
                  ),
                  Positioned(
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: _showAvatarPicker,
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: const CircleBorder(
                          side: BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow('Email', _email),
              _buildInfoRow('Username', _usernameController.text),
              _buildInfoRow('Phone', _phoneController.text),
              _buildInfoRow('Description', _descriptionController.text),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditProfile,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.edit),
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

