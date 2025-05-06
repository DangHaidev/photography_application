import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/Thuan.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Thuận Phạm',
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
                    value: 'thuan23082004@gmail.com',
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

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child:
                      const Text('Logout', style: TextStyle(fontSize: 16)),
                    ),
                  ),

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
          _buildBottomNavBar(),
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

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 0.5),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home, 0),
          _buildNavBarItem(Icons.group, 1),
          _buildNavBarItem(Icons.add_circle_outline, 2),
          _buildNavBarItem(Icons.search, 3),
          _buildNavBarItem(null, 4, isAvatar: true),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData? icon, int index, {bool isAvatar = false}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: isAvatar
          ? Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.black : Colors.transparent,
        ),
        child: const CircleAvatar(
          radius: 15,
          backgroundImage: AssetImage('assets/images/Thuan.png'),
        ),
      )
          : Icon(
        icon,
        color: isSelected ? Colors.black : Colors.grey,
        size: 28,
      ),
    );
  }
}
