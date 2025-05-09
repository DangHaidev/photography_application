import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/domain/models/Post.dart';
import '../../../core/domain/models/User.dart';
import '../../../core/domain/models/Comment.dart';
import '../../widget_build/CommentItemWidget.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import '../../blocs/post/post_state.dart';

Future<User?> fetchUserById(String userId) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return User.fromMap(doc.id, data);
    } else {
      return null; // Return null if user does not exist
    }
  } catch (e) {
    print('Error fetching user: $e');
    return null; // Return null in case of error
  }
}

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
  List<Comment> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostData() async {
    try {
      // Fetch post document from Firestore
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (!postDoc.exists) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create Post object
      final post = Post.fromMap(postDoc.id, postDoc.data()!);

      // Fetch author information if not provided
      User? author = widget.postAuthor;
      if (author == null && post.userId.isNotEmpty) {
        author = await fetchUserById(post.userId);
      }

      // Fetch comments
      final commentsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();

      List<Comment> comments = [];
      for (var doc in commentsSnapshot.docs) {
        comments.add(Comment.fromJson(doc.data()..['id'] = doc.id));
      }

      setState(() {
        _post = post;
        _author = author;
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading post data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to comment')),
        );
        return;
      }

      final commentData = {
        'userId': currentUser.uid,
        'content': _commentController.text.trim(),
        'createdAt': Timestamp.now(),
        'likeCount': 0,
      };

      // Add top-level comment
      final commentRef = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add(commentData);

      // Update comment count in post
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'commentCount': FieldValue.increment(1),
      });

      setState(() {
        _comments.insert(
          0,
          Comment(
            id: commentRef.id,
            userId: currentUser.uid,
            content: _commentController.text.trim(),
            createdAt: Timestamp.now(),
            likeCount: 0,
          ),
        );
      });

      _commentController.clear();
    } catch (e) {
      print("Error adding comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add comment')),
      );
    }
  }

  Future<void> _likeComment(Comment comment, int index) async {
    try {
      final commentRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(comment.id);
      await commentRef.update({
        'likeCount': comment.likeCount + 1,
      });
      setState(() {
        _comments[index] = comment.copyWith(
          likeCount: comment.likeCount + 1,
        );
      });
    } catch (e) {
      print("Error liking comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to like comment')),
      );
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
        child: Text('This post does not exist or has been deleted.'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostImage(),
          if (_post!.caption.isNotEmpty) _buildCaption(),
          _buildInteractionRow(),
          _buildAuthorRow(),
          const Divider(thickness: 0.5),
          _buildCommentsSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    if (_post!.imageUrls.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    }

    return Image.network(
      _post!.imageUrls.first,
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
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        _post!.caption,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildInteractionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          BlocBuilder<PostBloc, PostState>(
            builder: (context, postState) {
              // Kiểm tra trạng thái PostLoaded và cập nhật _post nếu cần
              if (postState is PostLoaded) {
                // Tìm bài viết tương ứng trong danh sách posts của PostBloc
                final updatedPost = postState.posts
                    .firstWhere((post) => post.id == _post!.id, orElse: () => _post!);
                // Cập nhật _post trong setState để phản ánh likeCount mới
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _post = updatedPost;
                    });
                  }
                });
              }

              final isLiked = (postState is PostLoaded)
                  ? postState.likedPosts.contains(_post!.id)
                  : false;
              return GestureDetector(
                onTap: () {
                  context.read<PostBloc>().add(LikePostEvent(_post!.id));
                },
                child: Row(
                  children: [
                    Icon(
                      isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                      color: isLiked ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _post!.likeCount.toString(), // Sẽ hiển thị giá trị mới
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              const Icon(FontAwesomeIcons.commentDots, size: 24),
              const SizedBox(width: 8),
              Text(
                _post!.commentCount.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(width: 16),
          const Icon(FontAwesomeIcons.bookmark, size: 24),
          const SizedBox(width: 16),
          const Icon(FontAwesomeIcons.ellipsis, size: 24),
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
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final isOwnPost = currentUser != null && _post != null && currentUser.uid == _post!.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _author?.name ?? 'Unknown User',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${_author?.totalFollowers ?? 0} Follower${_author?.totalFollowers == 1 ? '' : 's'} · ${_author?.totalPosts ?? 0} Post${_author?.totalPosts == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          if (!isOwnPost)
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

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _comments.isEmpty
              ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text('No comments yet.')),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return CommentItemWidget(
                comment: comment,
                level: 0,
                onLike: () => _likeComment(comment, index),
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _addComment(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}