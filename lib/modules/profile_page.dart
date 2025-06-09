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
  String _selectedBackground = 'assets/images/backgrounds/default.jpg';

  @override
  void initState() {
    super.initState();
    final user = UserData.getCurrentUser();
    _email = user?['email'] ?? '';
    _usernameController = TextEditingController(text: user?['username'] ?? '');
    _phoneController = TextEditingController(text: user?['phone'] ?? '');
    _descriptionController = TextEditingController(text: user?['description'] ?? '');
    _selectedAvatar = user?['avatar'] ?? _selectedAvatar;
    _selectedBackground = user?['background'] ?? _selectedBackground;
  }

  void _updateUserData() {
    final current = UserData.getCurrentUser() ?? {};
    UserData.updateCurrentUser({
      ...current,
      'avatar': _selectedAvatar,
      'background': _selectedBackground,
      'username': _usernameController.text,
      'phone': _phoneController.text,
      'description': _descriptionController.text,
      'email': _email,
    });
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
            _updateUserData();
          });
        },
      ),
    );
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            _buildOptionTile(Icons.person, 'Change Avatar', () {
              Navigator.pop(context);
              _showImagePicker(
                type: 'avatar',
                images: [
                  'assets/images/avatars/avatars1.png',
                  'assets/images/avatars/avatars2.png',
                  'assets/images/avatars/avatars3.png',
                  'assets/images/avatars/avatars4.png',
                  'assets/images/avatars/avatars5.png',
                ],
                defaultImage: 'assets/images/avatars/profile.jpg',
              );
            }),
            _buildOptionTile(Icons.image, 'Change Background', () {
              Navigator.pop(context);
              _showImagePicker(
                type: 'background',
                images: [
                  'assets/images/backgrounds/bg1.jpg',
                  'assets/images/backgrounds/bg2.jpg',
                  'assets/images/backgrounds/bg3.jpg',
                  'assets/images/backgrounds/bg4.jpg',
                  'assets/images/backgrounds/bg5.jpg',
                ],
                defaultImage: 'assets/images/backgrounds/default.jpg',
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  void _showImagePicker({
  required String type,
  required List<String> images,
  required String defaultImage,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey[900],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Your ${type == 'avatar' ? 'Avatar' : 'Background'}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 16),
          
          // Use SizedBox to prevent infinite height error
          SizedBox(
            height: type == 'avatar' ? 180 : 200,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: images.length,
              scrollDirection: Axis.horizontal, // Make it horizontal scroll
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: type == 'avatar' ? 100 : 180,
                mainAxisExtent: type == 'avatar' ? 100 : 280, // width of each item
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: type == 'avatar' ? 1 : 2.5, // Wider for backgrounds
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (type == 'avatar') {
                        _selectedAvatar = images[index];
                      } else {
                        _selectedBackground = images[index];
                      }
                      _updateUserData();
                    });
                    Navigator.pop(context);
                  },
                  child: type == 'avatar'
                      ? CircleAvatar(
                          backgroundImage: AssetImage(images[index]),
                          backgroundColor: Colors.transparent,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              setState(() {
                if (type == 'avatar') {
                  _selectedAvatar = defaultImage;
                } else {
                  _selectedBackground = defaultImage;
                }
                _updateUserData();
              });
              Navigator.pop(context);
            },
            icon: const Icon(Icons.restore, color: Colors.white),
            label: Text(
              'Use Default ${type == 'avatar' ? 'Avatar' : 'Background'}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800), // 👈 limits the width
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background image with rounded corners
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        _selectedBackground,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Dark overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    // Avatar at bottom-left
                    Positioned(
                      bottom: -40,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.purpleAccent],
                          ),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(_selectedAvatar),
                        ),
                      ),
                    ),

                    // Edit button to the right of avatar
                    Positioned(
                      bottom: -28,
                      left: 130,
                      child: Material(
                        color: Colors.black87,
                        shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _showEditOptions,
                          iconSize: 26,
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // 👈 Space for the overlapping avatar


              const SizedBox(height: 32),
              _buildInfoTile(Icons.email, 'Email', _email),
              _buildInfoTile(Icons.person, 'Username', _usernameController.text),
              _buildInfoTile(Icons.phone, 'Phone', _phoneController.text),
              _buildInfoTile(Icons.info, 'Description', _descriptionController.text),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditProfile,
        label: const Text('Edit Profile'),
        icon: const Icon(Icons.edit),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}

