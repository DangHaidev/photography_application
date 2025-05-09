import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/models/Post.dart';
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
import '../../../core/domain/models/User.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _trendingScrollController;
  late ScrollController _followingScrollController;
  bool _isAppBarVisible = true;
  double _lastTrendingOffset = 0;
  double _lastFollowingOffset = 0;
  late User user;
  bool _isLoading = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _trendingScrollController = ScrollController()..addListener(_handleTrendingScroll);
    _followingScrollController = ScrollController()..addListener(_handleFollowingScroll);

    _initializeUserAndData();
  }

  Future<void> _initializeUserAndData() async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        user = User.fromFirebaseUser(null);
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    user = User.fromFirebaseUser(currentUser);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (doc.exists) {
        setState(() {
          user = User.fromMap(currentUser.uid, doc.data()!);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {

      setState(() {
        _isLoading = false;
      });
    }

    context.read<PostBloc>().add(FetchPostsEvent(context: context));
    context.read<FollowBloc>().add(FetchFollowingsEvent(userId: currentUser.uid));
  }

  void _handleTrendingScroll() {
    final offset = _trendingScrollController.offset;
    if (offset > _lastTrendingOffset && _isAppBarVisible) {
      setState(() => _isAppBarVisible = false);
    } else if (offset < _lastTrendingOffset && !_isAppBarVisible) {
      setState(() => _isAppBarVisible = true);
    }
    _lastTrendingOffset = offset;

    if (_trendingScrollController.position.extentAfter < 300 && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<PostBloc>().add(FetchMorePostsEvent(context: context));
    }
  }

  void _handleFollowingScroll() {
    final offset = _followingScrollController.offset;
    if (offset > _lastFollowingOffset && _isAppBarVisible) {
      setState(() => _isAppBarVisible = false);
    } else if (offset < _lastFollowingOffset && !_isAppBarVisible) {
      setState(() => _isAppBarVisible = true);
    }
    _lastFollowingOffset = offset;

    if (_followingScrollController.position.extentAfter < 300 && !_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      context.read<PostBloc>().add(FetchMorePostsEvent(isFollowingTab: true, context: context));
    }
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Cache loaded post IDs and user IDs
    final loadedPostIds = <String>{};
    final loadedUserIds = <String>{};
    List<Post>? lastProcessedPosts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isAppBarVisible
          ? AppBar(
        title: const Text('Home'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Trending'),
            Tab(text: 'Following'),
          ],
        ),
      )
          : null,
      body: BlocListener<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostLoaded) {
            if (lastProcessedPosts == state.posts) {
              return;
            }
            lastProcessedPosts = state.posts;

            final newPostIds = state.posts
                .map((e) => e.id)
                .where((id) => !loadedPostIds.contains(id))
                .toList();
            if (newPostIds.isNotEmpty) {
              context.read<CommentBloc>().add(FetchCommentCountsEvent(postIds: newPostIds));
              loadedPostIds.addAll(newPostIds);
            }

            final newUserIds = state.posts
                .map((e) => e.userId)
                .toSet()
                .where((id) => id.isNotEmpty && !loadedUserIds.contains(id))
                .toList();
            if (newUserIds.isNotEmpty) {
              for (var userId in newUserIds) {
                context.read<UserBloc>().add(FetchUserInfoEvent(userId));
                loadedUserIds.add(userId);
              }
            }
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPostList(_trendingScrollController),
            _buildPostList(_followingScrollController, isFollowingTab: true),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BottomNavBar(
          selectedIndex: 0,
          user: user,
        ),
      ),
    );
  }

  Widget _buildPostList(ScrollController controller, {bool isFollowingTab = false}) {
    return BlocBuilder<PostBloc, PostState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (current is PostLoaded && previous is PostLoaded) {
          return previous.posts != current.posts || previous.hasMore != current.hasMore;
        }
        return true;
      },
      builder: (context, postState) {
        if (postState is PostLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _isLoadingMore = false);
            }
          });
        }

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
                  onPressed: () => context.read<PostBloc>().add(FetchPostsEvent(context: context)),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        } else if (postState is PostLoaded) {
          return BlocBuilder<FollowBloc, FollowState>(
            buildWhen: (previous, current) {
              if (previous.runtimeType != current.runtimeType) return true;
              if (current is FollowSuccessState && previous is FollowSuccessState) {
                return previous.followings != current.followings;
              }
              return true;
            },
            builder: (context, followState) {
              List<String> followingUserIds = [];
              if (followState is FollowSuccessState) {
                followingUserIds = followState.followings;
              } else if (followState is FollowErrorState && isFollowingTab) {
                return Center(child: Text('Lỗi: ${followState.errorMessage}'));
              } else if (followState is FollowLoadingState && isFollowingTab) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = isFollowingTab
                  ? postState.posts.where((p) => followingUserIds.contains(p.userId)).toList()
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
                  context.read<PostBloc>().add(FetchPostsEvent(
                    isFollowingTab: isFollowingTab,
                    context: context,
                  ));
                  final postIds = posts.map((e) => e.id).toList();
                  context.read<CommentBloc>().add(FetchCommentCountsEvent(postIds: postIds));
                },
                child: CustomScrollView(
                  key: Key(isFollowingTab ? 'following' : 'trending'),
                  controller: controller,
                  cacheExtent: 1000,
                  slivers: [
                    const SliverPadding(padding: EdgeInsets.only(top: 20)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => PostItemWidget(
                          key: ValueKey(posts[index].id),
                          post: posts[index],
                        ),
                        childCount: posts.length,
                      ),
                    ),
                    if (_isLoadingMore && postState.hasMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    if (!postState.hasMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('Đã tải hết bài đăng')),
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