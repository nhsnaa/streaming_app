import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_data.dart'; // For accessing logged-in user

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _loadFeedback(); // Load stored feedback on init
  }

  // Load feedback history from SharedPreferences
  Future<void> _loadFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'feedback_${UserData.loggedInUser}';
    final feedbackJsonList = prefs.getStringList(key) ?? [];

    setState(() {
      _feedbackList = feedbackJsonList
          .map((entry) => jsonDecode(entry) as Map<String, dynamic>)
          .toList();
    });
  }

  // Save new feedback to SharedPreferences
  Future<void> _submitFeedback() async {
    final feedbackText = _controller.text.trim();
    if (feedbackText.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'feedback_${UserData.loggedInUser}';

    final now = DateTime.now();
    final formattedTime = DateFormat('d MMMM yyyy, h:mm a').format(now);

    final newEntry = {
      'feedback': feedbackText,
      'timestamp': formattedTime,
    };

    final feedbackJsonList = prefs.getStringList(key) ?? [];
    feedbackJsonList.insert(0, jsonEncode(newEntry)); // Add to top of list

    await prefs.setStringList(key, feedbackJsonList);

    _controller.clear();
    _loadFeedback(); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // FEEDBACK FORM
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your feedback about this app...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1C1C1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  icon: const Icon(Icons.send, color: Colors.black),
                  label: const Text('Submit', style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24),

          // FEEDBACK HISTORY
          Expanded(
            child: _feedbackList.isEmpty
                ? const Center(
                    child: Text(
                      'No feedback submitted yet.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _feedbackList.length,
                    itemBuilder: (context, index) {
                      final feedback = _feedbackList[index];
                      return Card(
                        color: const Color(0xFF1C1C1E),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            feedback['feedback'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            feedback['timestamp'],
                            style: const TextStyle(color: Colors.white54),
                          ),
                          leading: const Icon(Icons.feedback, color: Colors.white38),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
