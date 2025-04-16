import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:firebase_auth/firebase_auth.dart';

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

    _trendingScrollController =
        ScrollController()..addListener(_handleTrendingScroll);
    _followingScrollController =
        ScrollController()..addListener(_handleFollowingScroll);

    // Fetch posts when the screen is initialized
    context.read<PostBloc>().add(FetchPostsEvent());

    // Sử dụng user124 làm currentUserId tạm thời
    const currentUserId = 'user124';
    debugPrint('HomeScreen: currentUserId: $currentUserId');
    context.read<FollowBloc>().add(FetchFollowingsEvent(userId: currentUserId));

    // Listen for PostLoadedState and trigger FetchCommentCountsEvent + FetchUserInfoEvent
    context.read<PostBloc>().stream.listen((state) {
      if (state is PostLoaded) {
        final postIds = state.posts.map((e) => e.id).toList();
        context.read<CommentBloc>().add(
          FetchCommentCountsEvent(postIds: postIds),
        );
        // Fetch user info for all unique userIds
        final userIds = state.posts.map((e) => e.userId).toSet().toList();
        debugPrint('HomeScreen: Đang tải dữ liệu cho userIds: $userIds');
        for (var userId in userIds) {
          if (userId.isNotEmpty) {
            context.read<UserBloc>().add(FetchUserInfoEvent(userId));
          }
        }
      }
    });
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
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildPostList(_trendingScrollController),
              _buildPostList(_followingScrollController, isFollowingTab: true),
            ],
          ),
          _buildAnimatedAppBar(),
        ],
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
                  onPressed:
                      () => context.read<PostBloc>().add(FetchPostsEvent()),
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
                debugPrint(
                  'HomeScreen: followingUserIds cho tab Following: $followingUserIds',
                );
              } else if (followState is FollowErrorState) {
                debugPrint(
                  'HomeScreen: FollowErrorState - ${followState.errorMessage}',
                );
                if (isFollowingTab) {
                  return const Center(
                    child: Text('Lỗi khi tải danh sách theo dõi'),
                  );
                }
              } else if (followState is FollowLoadingState) {
                if (isFollowingTab) {
                  return const Center(child: CircularProgressIndicator());
                }
              } else {
                debugPrint(
                  'HomeScreen: Trạng thái FollowBloc: ${followState.runtimeType}',
                );
                if (isFollowingTab) {
                  return const Center(
                    child: Text('Đang tải danh sách theo dõi...'),
                  );
                }
              }

              final posts =
                  isFollowingTab
                      ? postState.posts
                          .where((p) => followingUserIds.contains(p.userId))
                          .toList()
                      : postState.posts;

              debugPrint(
                'HomeScreen: Số bài đăng trong tab ${isFollowingTab ? "Following" : "Trending"}: ${posts.length}',
              );

              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    isFollowingTab
                        ? 'Chưa theo dõi ai hoặc không có bài đăng'
                        : 'Không có bài đăng nào',
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PostBloc>().add(FetchPostsEvent());
                  final postIds = posts.map((e) => e.id).toList();
                  context.read<CommentBloc>().add(
                    FetchCommentCountsEvent(postIds: postIds),
                  );
                },
                child: CustomScrollView(
                  controller: controller,
                  cacheExtent: 1000,
                  slivers: [
                    const SliverPadding(padding: EdgeInsets.only(top: 120)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return PostItemWidget(post: posts[index]);
                      }, childCount: posts.length),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('Không có dữ liệu'));
        }
      },
    );
  }

  Widget _buildAnimatedAppBar() {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      offset: _isAppBarVisible ? Offset.zero : const Offset(0, -1),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Image.asset("assets/images/logo.jpg", height: 32),
                const SizedBox(width: 8),
                const Text(
                  "Pexels App",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.teal,
              tabs: const [Tab(text: "Trending"), Tab(text: "Following")],
            ),
          ],
        ),
      ),
    );
  }
}
