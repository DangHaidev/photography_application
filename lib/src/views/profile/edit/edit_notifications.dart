import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino for iOS icons

class EditNotificationsPage extends StatefulWidget {
  const EditNotificationsPage({super.key});

  @override
  State<StatefulWidget> createState() => _EditNotificationsPageState();
}

class _EditNotificationsPageState extends State<EditNotificationsPage> {
  int _selectedIndex = 4;

  // Notification settings
  bool _receiveDownloadEmail = true;
  bool _receiveShareEmail = false;
  bool _receiveMonthlyStats = true;
  bool _receivePhotographerNews = true;
  bool _receiveMilestoneEmail = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.black), // iOS-style back icon
              padding: const EdgeInsets.only(left: 0),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Row(
                children: [
                  Text("Profile", style: TextStyle(color: Colors.grey[400], fontSize: 22)),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                  const Text("Notifications", style: TextStyle(color: Colors.black, fontSize: 22)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          // Push Notifications section with "Setup now" button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Push Notifications",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text(
                        "Setup now",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Email notification options
          _buildNotificationOption(
            "Receive an email asking to share how I used downloads?",
            _receiveDownloadEmail,
                (val) => setState(() => _receiveDownloadEmail = val),
          ),

          _buildNotificationOption(
            "Receive an email when someone shares how they used my media?",
            _receiveShareEmail,
                (val) => setState(() => _receiveShareEmail = val),
          ),

          _buildNotificationOption(
            "Receive monthly email with stats about your uploads?",
            _receiveMonthlyStats,
                (val) => setState(() => _receiveMonthlyStats = val),
          ),

          _buildNotificationOption(
            "Receive photographer related news?",
            _receivePhotographerNews,
                (val) => setState(() => _receivePhotographerNews = val),
          ),

          _buildNotificationOption(
            "Receive an email when reaching a new milestone?",
            _receiveMilestoneEmail,
                (val) => setState(() => _receiveMilestoneEmail = val),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(String title, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black
                  ),
                ),
              ),
              value
                  ? const Icon(Icons.check, color: Colors.black)
                  : const Icon(Icons.close, color: Colors.black),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
