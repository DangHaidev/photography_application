import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fluro/fluro.dart';
import 'package:photography_application/core/blocs/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/domain/models/Post.dart';
import '../../../core/domain/models/User.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';
import '../layout/bottom_nav_bar.dart';
import 'package:photography_application/core/navigation/router.dart';

class ProfileMePage extends StatefulWidget {
  const ProfileMePage({super.key});

  @override
  State<ProfileMePage> createState() => _ProfileMePageState();
}

class _ProfileMePageState extends State<ProfileMePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showMiddleProfile = true;
  int _selectedIndex = 4;
  User? user; // Custom User model
  bool _isLoading = true; // Track loading state
  List<Post> _userPosts = [];
  List<Post> _likedPosts = []; // Kept as is
  List<Post> _downloadedPosts = []; // Kept as is

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeBlocs();
  }

  void _initializeBlocs() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setState(() {
        user = User.fromFirebaseUser(null);
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.router.navigateTo(context, "/loginScreen", transition: TransitionType.fadeIn);
      });
      return;
    }

    // Gửi sự kiện để lấy thông tin người dùng
    context.read<UserBloc>().add(FetchUserInfoEvent(firebaseUser.uid));

    // Gọi trực tiếp fetchPostsForUser từ PostBloc
    try {
      final postBloc = context.read<PostBloc>();
      final userPosts = await postBloc.fetchPostsForUser(firebaseUser.uid);
      print("Fetched posts: $userPosts"); // Debug log
      setState(() {
        _userPosts = userPosts;
        if (user != null) {
          user = user!.copyWith(totalPosts: _userPosts.length);
        }
        _isLoading = false;
      });
    } catch (e) {
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

  Future<void> signOut() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    AppRouter.router.navigateTo(context, "/loginScreen", transition: TransitionType.fadeIn);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white10,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<UserBloc, UserState>(
              listener: (context, state) {
                if (state is UserInfoLoadedState) {
                  final userData = state.users[state.users.keys.first];
                  if (userData != null) {
                    setState(() {
                      user = User.fromMap(state.users.keys.first, userData);
                      _isLoading = false;
                    });
                  }
                } else if (state is UserErrorState) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
            ),
          ],
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
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
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        user: user ?? User.fromFirebaseUser(null),
        isCurrentUser: true,
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(user!.avatarUrl),
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
        const SizedBox(height: 8),
        Text(
          user!.bio.isNotEmpty ? user!.bio : 'No bio available',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem(user!.totalPosts.toString(), 'Posts'),
            _buildVerticalDivider(),
            _buildStatItem(user!.totalDownloadPosts.toString(), 'Downloads'),
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
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
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
                  labelColor: Theme.of(context).colorScheme.secondary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSecondary,
                  indicatorColor: Theme.of(context).colorScheme.secondary,
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

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
                    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
                    if (firebaseUser != null) {
                      try {
                        final postBloc = context.read<PostBloc>();
                        final userPosts = await postBloc.fetchPostsForUser(firebaseUser.uid);
                        print("Refreshed posts: $userPosts"); // Debug log
                        setState(() {
                          _userPosts = userPosts;
                          if (user != null) {
                            user = user!.copyWith(totalPosts: _userPosts.length);
                          }
                          _isLoading = false;
                        });
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Không thể tải bài đăng: $e")),
                        );
                      }
                    } else {
                      setState(() {
                        _isLoading = false;
                      });
                    }
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
      padding: const EdgeInsets.all(4),
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
                              0, post.caption.length > 10 ? 10 : post.caption.length) + '...'
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
        _downloadedPosts.isEmpty
            ? _buildEmptyBox('No downloads yet')
            : _buildPostsGrid(_downloadedPosts),
      ],
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
            color: Theme.of(context).colorScheme.onSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: _userPosts.isEmpty
                ? const Text('No statistics available')
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Likes: ${_userPosts.fold(0, (sum, post) => sum + post.likeCount)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Posts: ${_userPosts.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Average Likes: ${_userPosts.isEmpty ? 0 : (_userPosts.fold(0, (sum, post) => sum + post.likeCount) / _userPosts.length).toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
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
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text((user['name'] as String)[0],
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          title: Text(user['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text('${user['likes']} likes',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        );
      }).toList(),
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

  Widget _buildEmptyBox(String message) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          ],
        ),
      ),
    );
  }
}