import 'package:flutter/material.dart';
import 'package:streaming_app/modules/setting_page.dart';
import 'package:streaming_app/services/user_data.dart';
import 'package:streaming_app/widgets/edit_profile_sheet.dart';

class ProfilePopupContent extends StatefulWidget {
  const ProfilePopupContent({super.key});

  @override
  State<ProfilePopupContent> createState() => _ProfilePopupContentState();
}

class _ProfilePopupContentState extends State<ProfilePopupContent> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;

  String _email = '';
  String _selectedAvatar = 'assets/images/avatars/profile.jpg';
  String _selectedBackground = 'assets/images/backgrounds/default.jpg';

  @override
  void initState() {
    super.initState();
    final user = UserData.getCurrentUser() ?? {};
    _email = user['email'] ?? '';
    _usernameController = TextEditingController(text: user['username'] ?? '');
    _phoneController = TextEditingController(text: user['phone'] ?? '');
    _descriptionController = TextEditingController(text: user['description'] ?? '');
    _selectedAvatar = user['avatar'] ?? _selectedAvatar;
    _selectedBackground = user['background'] ?? _selectedBackground;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateUserData() {
    UserData.updateCurrentUser({
      ...UserData.getCurrentUser() ?? {},
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
          if (!mounted) return;
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
                images: List.generate(5, (i) => 'assets/images/avatars/avatars${i + 1}.png'),
                defaultImage: 'assets/images/avatars/profile.jpg',
              );
            }),
            _buildOptionTile(Icons.image, 'Change Background', () {
              Navigator.pop(context);
              _showImagePicker(
                type: 'background',
                images: List.generate(5, (i) => 'assets/images/backgrounds/bg${i + 1}.jpg'),
                defaultImage: 'assets/images/backgrounds/default.jpg',
              );
            }),
          ],
        ),
      ),
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
            SizedBox(
              height: type == 'avatar' ? 120 : 220,
              child: GridView.builder(
                scrollDirection: Axis.vertical,
                itemCount: images.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: type == 'avatar' ? 100 : 220,
                  mainAxisExtent: type == 'background' ? 100 : type == 'avatar' ? 100 : 280, //size avatar and background
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: type == 'avatar' ? 1 : 2.5,
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
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20), //boarder round for background
                            child: Image.asset(images[index], fit: BoxFit.cover),
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

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(label, style: const TextStyle(color: Colors.white70)),
        subtitle: Text(value.isNotEmpty ? value : 'Not set', style: const TextStyle(color: Colors.white30)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      _selectedBackground,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Settings icon (top-right)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsPage()),
                        );
                      },
                    ),
                  ),
                  // Profile avatar (bottom-left)
                  Positioned(
                    bottom: -40,
                    left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: 50, // size circle
                          backgroundImage: AssetImage(_selectedAvatar),
                        ),
                      ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showEditOptions,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black38,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.edit, size: 20, color: Colors.white60),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 50),
              _buildInfoTile(Icons.email, 'Email', _email),
              _buildInfoTile(Icons.person, 'Username', _usernameController.text),
              _buildInfoTile(Icons.phone, 'Phone', _phoneController.text),
              _buildInfoTile(Icons.info, 'Description', _descriptionController.text),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openEditProfile,
                icon: const Icon(Icons.edit, color: Colors.black),
                label: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close", style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
