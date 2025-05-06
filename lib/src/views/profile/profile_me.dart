import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../layout/bottom_nav_bar.dart';
import 'package:photography_application/core/navigation/router.dart';

//Truyền id người đăng nhập

class ProfileMePage extends StatefulWidget {
  const ProfileMePage({super.key});

  @override
  State<ProfileMePage> createState() => _ProfileMePageState();
}

class _ProfileMePageState extends State<ProfileMePage> with SingleTickerProviderStateMixin {

  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName = "Loading..."; // Giá trị mặc định khi đang tải
  String? userEmail = "Loading...";

  late TabController _tabController;
  bool _showMiddleProfile = true;
  int _selectedIndex = 4;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    AppRouter.router.navigateTo(context, "/loginScreen", transition: TransitionType.fadeIn);
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData(); // Tải dữ liệu người dùng khi khởi tạo
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
          });
        }
      } catch (e) {
        print("Error loading user data: $e");
        setState(() {
          userName = "Error";
          userEmail = "Error";
        });
      }
    } else {
      setState(() {
        userName = "Not logged in";
        userEmail = "Not logged in";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            const SizedBox(height: 30),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: !_showMiddleProfile ? _buildAppBar() : const SizedBox.shrink(),
              ),
            ),
            Positioned(
              top: 10,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.settings, size: 24, color: Colors.white),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showMiddleProfile ? 80 : -200,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showMiddleProfile ? 1.0 : 0.0,
                child: _buildProfileHeader(),
              ),
            ),
            _buildSlidingPanel(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(radius: 15, backgroundImage: AssetImage('assets/images/Thuan.png')),
          SizedBox(width: 8),
          Text(
            userName ?? "Unknown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/images/Thuan.png')),
        const SizedBox(height: 16),
        Text(
          userName ?? "Unknown",
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSocialIcon(FontAwesomeIcons.globe, 'https://yourwebsite.com'),
              _buildSocialIcon(FontAwesomeIcons.instagram, 'https://instagram.com'),
              _buildSocialIcon(FontAwesomeIcons.facebookF, 'https://facebook.com'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem('0', 'Total views'),
            _buildVerticalDivider(),
            _buildStatItem('0', 'Total Dowloads'),
            _buildVerticalDivider(),
            _buildStatItem('0', 'Followers'),
          ],
        ),
      ],
    );
  }

  Widget _buildSlidingPanel() {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        setState(() {
          _showMiddleProfile = notification.extent < 0.75;
        });
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.40,
        minChildSize: 0.40,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(icon: Icon(Icons.image)),
                    Tab(icon: Icon(Icons.bookmark_border)),
                    Tab(icon: Icon(Icons.bar_chart)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPhotosTab(scrollController),
                      _buildBookmarksTab(scrollController),
                      _buildStatsTab(scrollController),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotosTab(ScrollController controller) {
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 3;
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/postDetail', arguments: {'postId': index}),
        child: Container(color: Colors.grey[300]),
      ),
    );
  }

  Widget _buildBookmarksTab(ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Your Likes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildEmptyBox('No images yet'),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your Downloads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
              child: const Icon(Icons.lock, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEmptyBox('No downloads yet'),
      ],
    );
  }

  Widget _buildStatsTab(ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Like Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(child: Text('Like Chart Placeholder')),
        ),
        const SizedBox(height: 32),
        const Text('Top Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildRankingList(),
      ],
    );
  }

  Widget _buildRankingList() {
    final users = [
      {'name': 'User 1', 'likes': 1500},
      {'name': 'User 2', 'likes': 1200},
      {'name': 'User 3', 'likes': 1000},
      {'name': 'User 4', 'likes': 800},
      {'name': 'User 5', 'likes': 500},
    ];
    return Column(
      children: users.map((user) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Text((user['name'] as String)[0]),
          ),
          title: Text(user['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text('${user['likes']} likes', style: const TextStyle(color: Colors.grey)),
        );
      }).toList(),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: 1,
      height: 40,
      color: Colors.grey[700],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              FaIcon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(url.replaceAll('https://', '').replaceAll('www.', ''),
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('No content yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
