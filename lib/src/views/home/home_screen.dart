import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/comment/comment_bloc.dart';
import '../../blocs/comment/comment_event.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';
import '../../blocs/follow/follow_bloc.dart';
import '../../blocs/follow/follow_event.dart';
import '../../blocs/follow/follow_state.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../widget_build/postItemWidget.dart';
import '../layout/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _trendingScrollController;
  late ScrollController _followingScrollController;
  bool _isAppBarVisible = true;
  double _lastTrendingOffset = 0;
  double _lastFollowingOffset = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _trendingScrollController = ScrollController()..addListener(_handleTrendingScroll);
    _followingScrollController = ScrollController()..addListener(_handleFollowingScroll);

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Lấy userId
    if (currentUserId.isEmpty) {
      // Nếu không có userId, điều hướng đến trang đăng nhập
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      // Nếu có userId, thực hiện các hành động cần thiết
      context.read<PostBloc>().add(FetchPostsEvent());
      context.read<FollowBloc>().add(FetchFollowingsEvent(userId: currentUserId));

      context.read<PostBloc>().stream.listen((state) {
        if (state is PostLoaded) {
          final postIds = state.posts.map((e) => e.id).toList();
          context.read<CommentBloc>().add(FetchCommentCountsEvent(postIds: postIds));
          final userIds = state.posts.map((e) => e.userId).toSet().toList();
          for (var userId in userIds) {
            if (userId.isNotEmpty) {
              context.read<UserBloc>().add(FetchUserInfoEvent(userId));
            }
          }
        }
      });
    }
  }


  void _handleTrendingScroll() {
    final offset = _trendingScrollController.offset;
    if (offset > _lastTrendingOffset && _isAppBarVisible) {
      setState(() => _isAppBarVisible = false);
    } else if (offset < _lastTrendingOffset && !_isAppBarVisible) {
      setState(() => _isAppBarVisible = true);
    }
    _lastTrendingOffset = offset;
  }

  void _handleFollowingScroll() {
    final offset = _followingScrollController.offset;
    if (offset > _lastFollowingOffset && _isAppBarVisible) {
      setState(() => _isAppBarVisible = false);
    } else if (offset < _lastFollowingOffset && !_isAppBarVisible) {
      setState(() => _isAppBarVisible = true);
    }
    _lastFollowingOffset = offset;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _trendingScrollController.dispose();
    _followingScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isAppBarVisible
          ? AppBar(
        title: const Text('Trang chủ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Xu hướng'),
            Tab(text: 'Đang theo dõi'),
          ],
        ),
      )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostList(_trendingScrollController),
          _buildPostList(_followingScrollController, isFollowingTab: true),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavBar(selectedIndex: 0),
      ),
    );
  }

  Widget _buildPostList(
      ScrollController controller, {
        bool isFollowingTab = false,
      }) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, postState) {
        if (postState is PostLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (postState is PostError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(postState.errorMessage),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => context.read<PostBloc>().add(FetchPostsEvent()),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        } else if (postState is PostLoaded) {
          return BlocBuilder<FollowBloc, FollowState>(
            builder: (context, followState) {
              List<String> followingUserIds = [];
              if (followState is FollowSuccessState) {
                followingUserIds = followState.followings;
              } else if (followState is FollowErrorState) {
                if (isFollowingTab) {
                  return Center(child: Text('Lỗi: ${followState.errorMessage}'));
                }
              } else if (followState is FollowLoadingState) {
                if (isFollowingTab) {
                  return const Center(child: CircularProgressIndicator());
                }
              }

              final posts = isFollowingTab
                  ? postState.posts
                  .where((p) => followingUserIds.contains(p.userId))
                  .toList()
                  : postState.posts;

              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    isFollowingTab
                        ? 'Bạn chưa theo dõi ai hoặc không có bài đăng.'
                        : 'Không có bài đăng nào.',
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostBloc>().add(FetchPostsEvent());
                  final postIds = posts.map((e) => e.id).toList();
                  context.read<CommentBloc>().add(FetchCommentCountsEvent(postIds: postIds));
                },
                child: CustomScrollView(
                  controller: controller,
                  cacheExtent: 1000,
                  slivers: [
                    const SliverPadding(padding: EdgeInsets.only(top: 20)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => PostItemWidget(post: posts[index]),
                        childCount: posts.length,
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                  ],
                ),
              );
            },
          );
        }
        return const Center(child: Text('Không có dữ liệu'));
      },
    );
  }
}