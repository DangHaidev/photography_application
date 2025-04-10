import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> photos = [];
  bool isLoading = true;
  late TabController _tabController;
  late ScrollController _scrollController;
  bool _isAppBarVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
    fetchPhotos();
  }

  void _handleScroll() {
    final offset = _scrollController.offset;

    if (offset > _lastScrollOffset && _isAppBarVisible) {
      setState(() => _isAppBarVisible = false);
    } else if (offset < _lastScrollOffset && !_isAppBarVisible) {
      setState(() => _isAppBarVisible = true);
    }

    _lastScrollOffset = offset;
  }

  Future<void> fetchPhotos() async {
    const apiKey = 'NRHEE16n80CaNkXEDKcbo8XrHxOJ0z4HI256Rmk9GIWJZvzznzzW7OY8';
    const url = 'https://api.pexels.com/v1/curated?per_page=30';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        photos = data['photos'];
        isLoading = false;
      });
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  Widget buildPostItem(dynamic photo) {
    final userAvatar = "https://i.pravatar.cc/150?img=${photo['id'] % 70}";
    final photographer = photo['photographer'];
    final imageUrl = photo['src']['large'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Row: avatar + name + follow
          Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(userAvatar), radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  photographer,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text("Follow"),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => const AspectRatio(
                aspectRatio: 3 / 2,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'không tìm thấy',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// Buttons
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 120, bottom: 20),
                itemCount: photos.length,
                itemBuilder: (context, index) =>
                    buildPostItem(photos[index]),
              ),
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 120, bottom: 20),
                itemCount: photos.length,
                itemBuilder: (context, index) =>
                    buildPostItem(photos[index]),
              ),
            ],
          ),

          /// AppBar + TabBar
          AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            offset: _isAppBarVisible ? Offset.zero : const Offset(0, -1),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 12),
                      Image.asset("assets/images/logo.jpg", height: 32),
                      const SizedBox(width: 8),
                      const Text(
                        "Pexels App",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
  }
}
