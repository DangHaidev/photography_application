import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
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
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Widget _buildNavBarItem(BuildContext context, IconData? icon, int index, {bool isAvatar = false}) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
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

  @override
  Widget build(BuildContext context) {
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
