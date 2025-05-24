import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import '../../../core/domain/models/User.dart';
import '../messages/chat_list_screen.dart';
import '../profile/profile_id.dart';
import '../search/search_widget.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final User? user; // Vẫn giữ để điều hướng, nhưng không dùng cho avatar
  final bool isCurrentUser;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.user,
    required this.isCurrentUser,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final currentUserData = firebaseUser != null ? User.fromFirebaseUser(firebaseUser) : null;

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatListScreen(currentUser: currentUserData!),
          ),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/create');
        break;
      case 3:
        Navigator.pushNamed(context, '/search');
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(user: user ?? currentUserData!),
          ),
        );
        break;
    }
  }

  Widget _buildNavBarItem(BuildContext context, IconData? icon, int index, {bool isAvatar = false}) {
    final isSelected = selectedIndex == index;

    // Lấy thông tin current user từ Firebase
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final currentUser = firebaseUser != null ? User.fromFirebaseUser(firebaseUser) : null;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: isAvatar
          ? Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.transparent,
        ),
        child: CircleAvatar(
          radius: 15,
          backgroundImage: currentUser != null
              ? NetworkImage(currentUser.avatarUrl)
              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          onBackgroundImageError: currentUser != null
              ? (error, stackTrace) {
            debugPrint('BottomNavBar: Error loading avatar: $error');
          }
              : null,
        ),
      )
          : Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onSecondary,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black, width: 0.5),
        ),
        color: Theme.of(context).primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(context, Icons.home, 0),
          _buildNavBarItem(context, Icons.chat, 1),
          _buildNavBarItem(context, Icons.add_circle_outline, 2),
          _buildNavBarItem(context, Icons.search, 3),
          _buildNavBarItem(context, null, 4, isAvatar: true),
        ],
      ),
    );
  }
}