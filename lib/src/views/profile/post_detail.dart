import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/models/Post.dart';
import '../../../core/domain/models/User.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final User? postAuthor;

  const PostDetailPage({
    super.key,
    required this.postId,
    this.postAuthor,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool _isLoading = true;
  Post? _post;
  User? _author;

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (!postDoc.exists) {
        setState(() => _isLoading = false);
        return;
      }

      final post = Post.fromMap(postDoc.id, postDoc.data()!);

      User? author = widget.postAuthor;
      if (author == null && post.userId.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(post.userId)
            .get();

        if (userDoc.exists) {
          author = User.fromMap(post.userId, userDoc.data()!);
        }
      }

      setState(() {
        _post = post;
        _author = author;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading post data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_author?.name ?? 'Unknown User'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.paperPlane),
            onPressed: () {
              // Share functionality
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_post == null) {
      return const Center(
        child: Text('This post could not be found or has been removed.'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (_post!.caption.isNotEmpty) _buildCaption(),
          _buildPostImage(),
          _buildInteractionRow(),
          const SizedBox(height: 8),
          _buildAuthorRow(),
          const SizedBox(height: 20),
          const Divider(thickness: 0.5),
          _buildPhotoInfo(),
          const Divider(thickness: 0.5),
          _buildMoreLikeThis(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return _post!.imageUrl.isNotEmpty
        ? Image.network(
      _post!.imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 300,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 300,
          color: Colors.grey[300],
          child: const Center(child: Icon(Icons.error, size: 50)),
        );
      },
    )
        : Container(
      height: 300,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
    );
  }

  Widget _buildInteractionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.heart),
          const SizedBox(width: 16),
          const Icon(FontAwesomeIcons.commentDots),
          const SizedBox(width: 16),
          const Icon(FontAwesomeIcons.bookmark),
          const SizedBox(width: 16),
          const Icon(FontAwesomeIcons.ellipsis),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              // Download functionality
            },
            icon: const Icon(FontAwesomeIcons.download, size: 16),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // CircleAvatar for the author's profile image
          CircleAvatar(
            backgroundImage: (_author?.avatarUrl != null && _author!.avatarUrl.isNotEmpty)
                ? NetworkImage(_author!.avatarUrl)
                : null,
            child: (_author?.avatarUrl == null || _author!.avatarUrl.isEmpty)
                ? const Icon(Icons.person)
                : null,
            radius: 20,
          ),
          const SizedBox(width: 10),

          // Column for displaying the author's name and follower/post info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Author name
              Text(
                _author?.name ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              // Author's followers and posts
              Text(
                '${_author?.totalFollowers ?? 0} Follower${_author?.totalFollowers == 1 ? '' : 's'} · ${_author?.totalPosts ?? 0} Post${_author?.totalPosts == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),

          // Follow button
          ElevatedButton.icon(
            onPressed: () {
              // Follow functionality
            },
            icon: const Icon(FontAwesomeIcons.plus, size: 14),
            label: const Text('Follow'),
          ),
        ],
      ),
    );
  }


  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          _post!.caption,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPhotoInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photo Information',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _InfoItem(
                  icon: FontAwesomeIcons.copyright,
                  label: 'License',
                  value: 'Free to Use',
                ),
                _InfoItem(
                  icon: FontAwesomeIcons.eye,
                  label: 'Views',
                  value: '5',
                ),
                _InfoItem(
                  icon: FontAwesomeIcons.arrowDown,
                  label: 'Downloads',
                  value: '5',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreLikeThis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(FontAwesomeIcons.image, size: 18),
              SizedBox(width: 8),
              Text('More like this',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            itemBuilder: (context, index) => Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              color: Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.white),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}
