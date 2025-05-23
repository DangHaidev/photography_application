import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/domain/models/Post.dart';
import '../../../core/domain/models/User.dart';
import '../../blocs/post/post_bloc.dart';
import '../layout/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  final User? user;
  const ProfilePage({required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showMiddleProfile = true;
  int _selectedIndex = 4;
  User? user;
  late bool isCurrentUser;
  bool _isLoading = true; // Track loading state
  List<Post> _userPosts = []; // Store user-specific posts
  List<Post> _likedPosts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    user = widget.user;

    // Kiểm tra xem user có phải là current user không
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    isCurrentUser = user != null && user!.id == currentUserId;

    // Lấy bài đăng của người dùng
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final postBloc = context.read<PostBloc>();
      final userPosts = await postBloc.fetchPostsForUser(user!.id);
      print("Fetched posts for user ${user!.id}: $userPosts"); // Debug log
      setState(() {
        _userPosts = userPosts;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching posts: $e"); // Debug log
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể tải bài đăng: $e")),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Không tìm thấy thông tin người dùng',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

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
                onTap: _showActionSheet,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.ellipsisH,
                    size: 24,
                    color: Colors.white,
                  ),
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        user: user,
        isCurrentUser: !isCurrentUser, // Sửa lại để truyền đúng giá trị
      ),
    );
  }

  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _blockAccount();
                },
                leading: const Icon(Icons.block, color: Colors.white),
                title: const Text('Block Account', style: TextStyle(color: Colors.white)),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _reportAccount();
                },
                leading: const Icon(Icons.report, color: Colors.white),
                title: const Text('Report Account', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _blockAccount() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Blocked')));
  }

  void _reportAccount() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Reported')));
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(user!.avatarUrl),
            onBackgroundImageError: (error, stackTrace) {
              debugPrint('ProfilePage: Error loading avatar: $error');
            },
          ),
          const SizedBox(width: 8),
          Text(
            user!.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(user!.avatarUrl),
          onBackgroundImageError: (error, stackTrace) {
            debugPrint('ProfilePage: Error loading avatar: $error');
          },
        ),
        const SizedBox(height: 16),
        Text(
          user!.name,
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
            _buildStatItem(user!.totalPosts.toString(), 'Total views'),
            _buildVerticalDivider(),
            _buildStatItem(user!.totalDownloadPosts.toString(), 'Total Downloads'),
            _buildVerticalDivider(),
            _buildStatItem(user!.totalFollowers.toString(), 'Followers'),
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
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPhotosTab(scrollController),
                      _buildBookmarksTab(scrollController),
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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userPosts.isEmpty) {
      return ListView(
        controller: controller,
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_camera, size: 50, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('No posts yet', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await _fetchUserPosts();
                  },
                  child: const Text('Refresh'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Posts found: ${_userPosts.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: _userPosts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/postDetail',
              arguments: {'postId': post.id, 'postauthor': user!.id},
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              post.imageUrls.isNotEmpty
                  ? Image.network(
                post.imageUrls.first,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading image: ${post.imageUrls.first}, error: $error");
                  return Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(height: 4),
                        Text(
                          post.caption.isNotEmpty
                              ? post.caption.substring(
                            0,
                            post.caption.length > 10
                                ? 10
                                : post.caption.length,
                          ) +
                              '...'
                              : 'No caption',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        post.likeCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookmarksTab(ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Your Likes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _likedPosts.isEmpty
            ? _buildEmptyBox('No liked images yet')
            : _buildPostsGrid(_likedPosts),
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
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
              Text(
                url.replaceAll('https://', '').replaceAll('www.', ''),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 50, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsGrid(List<Post> posts) {
    final crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/postDetail',
              arguments: {'postId': post.id, 'postauthor': user!.id},
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: post.imageUrls.isNotEmpty
                  ? Image.network(
                post.imageUrls.first,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading image: ${post.imageUrls.first}, error: $error");
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}