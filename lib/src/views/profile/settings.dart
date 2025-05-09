import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName = ""; // Default value while loading
  String? userEmail = "";
  String? userAvatarUrl = ""; // Avatar URL

  int _selectedIndex = 4;
  String _selectedLanguage = 'US English';

  final List<String> _languages = [
    'US English',
    'UK English',
    'Tiếng Việt',
    'Français',
    'Español',
    'Deutsch',
    '中文',
    '日本語',
    'Português',
    'Italiano',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data on initialization
  }

  Future<void> _loadUserData() async {
    final currentUser = user; // Local variable for type promotion
    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          setState(() {
            userName = doc.get('name') as String? ?? "Unknown";
            userEmail = doc.get('email') as String? ?? "Unknown";
            userAvatarUrl = doc.get('avatarUrl') as String? ?? ""; // Get avatar URL
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
        setState(() {
          userName = "Error";
          userEmail = "Error";
          userAvatarUrl = ""; // Error when fetching avatar
        });
      }
    } else {
      setState(() {
        userName = "Not logged in";
        userEmail = "Not logged in";
        userAvatarUrl = ""; // No logged-in user
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profileMe');
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                                image: userAvatarUrl != null && userAvatarUrl!.isNotEmpty
                                    ? DecorationImage(
                                  image: NetworkImage(userAvatarUrl!),
                                  fit: BoxFit.cover,
                                )
                                    : null, // Display avatar if URL is available
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              userName ?? "Unknown",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/editPersonalInfo');
                          },
                          child: const Icon(
                            Icons.chevron_right,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSettingsItem(
                    title: 'Email',
                    value: userEmail ?? "Unknown",
                    hasArrow: true,
                    icon: FontAwesomeIcons.envelope,
                    onTap: () {
                      Navigator.pushNamed(context, '/editEmail');
                    },
                  ),
                  _buildSettingsItem(
                    title: 'Instagram',
                    hasArrow: true,
                    icon: FontAwesomeIcons.instagram,
                    onTap: () {
                      Navigator.pushNamed(context, '/editInstagram');
                    },
                  ),
                  _buildSettingsItem(
                    title: 'Facebook',
                    hasArrow: true,
                    icon: FontAwesomeIcons.facebook,
                    onTap: () {
                      Navigator.pushNamed(context, '/editFacebook');
                    },
                  ),
                  _buildSettingsItem(
                    title: 'Website',
                    hasArrow: true,
                    icon: FontAwesomeIcons.link,
                    onTap: () {
                      Navigator.pushNamed(context, '/editWebsite');
                    },
                  ),
                  _buildSettingsItem(
                    title: 'Notifications',
                    hasArrow: true,
                    icon: FontAwesomeIcons.bell,
                    onTap: () {
                      Navigator.pushNamed(context, '/editNotifications');
                    },
                  ),
                  _buildSettingsItem(
                    title: 'Language',
                    value: _selectedLanguage,
                    hasArrow: true,
                    icon: FontAwesomeIcons.language,
                    onTap: () {
                      _showLanguageSelectionDialog();
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildGrayButton('About Pexels'),
                  const SizedBox(height: 10),
                  _buildGrayButton('Terms, Privacy & Copyright'),
                  const SizedBox(height: 20),
                  _buildLogoutButton(),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Delete my account',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show language selection dialog
  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_languages[index]),
                  trailing: _selectedLanguage == _languages[index]
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = _languages[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required String title,
    String? value,
    bool hasArrow = false,
    VoidCallback? onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black12, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(icon, color: Colors.grey[600]),
              ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            if (value != null)
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            if (hasArrow)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrayButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_outward, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            // Sign out the user
            await FirebaseAuth.instance.signOut();

            // After logging out, redirect to the login screen
            Navigator.pushReplacementNamed(context, '/loginScreen'); // Replace with your login route
          } catch (e) {
            // Handle sign-out errors
            print("Error logging out: $e");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Logout', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
