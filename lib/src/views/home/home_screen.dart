import 'package:flutter/material.dart';
import '../../blocs/homeScreen_bloc.dart';
import '../../blocs/user_bloc.dart';
import '../../widget_build/postItemWidget.dart';

class HomeScreen extends StatefulWidget {
  final HomescreenBloc homescreenBloc;

  const HomeScreen({super.key, required this.homescreenBloc});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late HomescreenBloc _bloc;
  late UserBloc _userBloc;
  late TabController _tabController;
  late ScrollController _trendingScrollController;
  late ScrollController _followingScrollController;
  bool _isAppBarVisible = true;
  double _lastTrendingOffset = 0;
  double _lastFollowingOffset = 0;

  @override
  void initState() {
    super.initState();
    _bloc = widget.homescreenBloc; // Use the passed bloc instance
    _userBloc = UserBloc(); // Initialize userBloc
    _tabController = TabController(length: 2, vsync: this);
    _trendingScrollController =
        ScrollController()..addListener(_handleTrendingScroll);
    _followingScrollController =
        ScrollController()..addListener(_handleFollowingScroll);
    _bloc.addListener(_onBlocUpdated);
    _bloc.fetchPosts();
  }

  void _onBlocUpdated() {
    if (mounted) setState(() {});
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
    _bloc.removeListener(_onBlocUpdated);
    _bloc.dispose();
    // _userBloc.dispose(); // Dispose userBloc to free up resources
    _tabController.dispose();
    _trendingScrollController.dispose();
    _followingScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bloc.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_bloc.error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_bloc.error!),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _bloc.fetchPosts(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildPostList(
                context,
                controller: _trendingScrollController,
                posts: _bloc.trendingPosts,
              ),
              _buildPostList(
                context,
                controller: _followingScrollController,
                posts: _bloc.followingPosts,
              ),
            ],
          ),
          _buildAnimatedAppBar(),
        ],
      ),
    );
  }

  Widget _buildPostList(
    BuildContext context, {
    required ScrollController controller,
    required List posts,
  }) {
    return RefreshIndicator(
      onRefresh: () async => _bloc.fetchPosts(),
      displacement: 80,
      child: CustomScrollView(
        controller: controller,
        slivers: [
          const SliverPadding(padding: EdgeInsets.only(top: 120)),
          posts.isEmpty
              ? SliverFillRemaining(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 120,
                    child: const Center(child: Text('Không có bài viết')),
                  ),
                ),
              )
              : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => PostItemWidget(
                    post: posts[index],
                    userBloc: _userBloc, // Passing userBloc to PostItemWidget
                    bloc: _bloc,
                  ),
                  childCount: posts.length,
                ),
              ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
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
