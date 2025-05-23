import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import '../../../core/domain/models/User.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final User? user;
  final bool isCurrentUser; // Thêm tham số để xác định current user

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.user,
    required this.isCurrentUser,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/community');
        break;
      case 2:
        Navigator.pushNamed(context, '/create');
        break;
      case 3:
        Navigator.pushNamed(context, '/search');
        break;
      case 4:
        Navigator.pushNamed(context, '/profileMe');
        break;
    }
  }

  Widget _buildNavBarItem(BuildContext context, IconData? icon, int index, {bool isAvatar = false}) {
    final isSelected = selectedIndex == index;

    // Lấy thông tin current user từ Firebase nếu đây là trang của current user
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final currentUser = firebaseUser != null ? User.fromFirebaseUser(firebaseUser) : null;

    // Quyết định avatar nào sẽ được hiển thị
    final displayUser = isCurrentUser && currentUser != null ? currentUser : user;

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
          backgroundImage: displayUser != null
              ? NetworkImage(displayUser.avatarUrl)
              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          onBackgroundImageError: displayUser != null
              ? (error, stackTrace) {
            debugPrint('BottomNavBar: Error loading avatar: $error');
          }
              : null,
        ),
      )
          : Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSecondary,
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
          _buildNavBarItem(context, Icons.group, 1),
          _buildNavBarItem(context, Icons.add_circle_outline, 2),
          _buildNavBarItem(context, Icons.search, 3),
          _buildNavBarItem(context, null, 4, isAvatar: true),
        ],
      ),
    );
  }
}