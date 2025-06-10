import 'package:flutter/material.dart';

class EditProfileSheet extends StatefulWidget {
  final String username;
  final String phone;
  final String description;
  final Function(Map<String, String>) onSave;

  const EditProfileSheet({
    super.key,
    required this.username,
    required this.phone,
    required this.description,
    required this.onSave,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    _usernameController = TextEditingController(text: widget.username);
    _phoneController = TextEditingController(text: widget.phone);
    _descriptionController = TextEditingController(text: widget.description);
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty')),
      );
      return;
    }

    widget.onSave({
      'username': _usernameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'description': _descriptionController.text.trim(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildField('Username', _usernameController, keyboardType: TextInputType.text, autofocus: true),
            _buildField('Phone', _phoneController, keyboardType: TextInputType.phone),
            _buildField('Description', _descriptionController, maxLines: 3),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text('Save', style:TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool autofocus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        autofocus: autofocus,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade700),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          fillColor: Colors.grey.shade800,
          filled: true,
        ),
      ),
    );
  }
}

