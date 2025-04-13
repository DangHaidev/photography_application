import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../blocs/homeScreen_bloc.dart';
import '../../widget_build/postItemWidget.dart';

class HomeScreenProvider extends StatelessWidget {
  const HomeScreenProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomescreenBloc>(
      create: (context) => HomescreenBloc(),
      child: const HomeSreenPage(),
    );
  }
}

class HomeSreenPage extends StatefulWidget {
  const HomeSreenPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeSreenPage();
}

class _HomeSreenPage extends State<HomeSreenPage>
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
    _trendingScrollController = ScrollController();
    _followingScrollController = ScrollController();
    _trendingScrollController.addListener(_handleTrendingScroll);
    _followingScrollController.addListener(_handleFollowingScroll);
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
    return Consumer<HomescreenBloc>(
      builder: (context, bloc, child) {
        if (bloc.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (bloc.error != null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(bloc.error!),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => bloc.fetchPosts(),
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
                  RefreshIndicator(
                    onRefresh: () => bloc.fetchPosts(),
                    displacement: 80,
                    child: CustomScrollView(
                      controller: _trendingScrollController,
                      slivers: [
                        const SliverPadding(padding: EdgeInsets.only(top: 120)),
                        bloc.trendingPosts.isEmpty
                            ? SliverFillRemaining(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 120,
                                  child: const Center(
                                    child: Text('Không có bài viết'),
                                  ),
                                ),
                              ),
                            )
                            : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => PostItemWidget(
                                  post: bloc.trendingPosts[index],
                                ),
                                childCount: bloc.trendingPosts.length,
                              ),
                            ),
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 20),
                        ),
                      ],
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: () => bloc.fetchPosts(),
                    displacement: 80,
                    child: CustomScrollView(
                      controller: _followingScrollController,
                      slivers: [
                        const SliverPadding(padding: EdgeInsets.only(top: 120)),
                        bloc.followingPosts.isEmpty
                            ? SliverFillRemaining(
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 120,
                                  child: const Center(
                                    child: Text('Không có bài viết'),
                                  ),
                                ),
                              ),
                            )
                            : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => PostItemWidget(
                                  post: bloc.followingPosts[index],
                                ),
                                childCount: bloc.followingPosts.length,
                              ),
                            ),
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AnimatedSlide(
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
                        tabs: const [
                          Tab(text: "Trending"),
                          Tab(text: "Following"),
                        ],
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
}
