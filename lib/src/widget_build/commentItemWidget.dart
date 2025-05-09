import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/domain/models/User.dart' as app_user;
import '../../core/domain/models/Comment.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../blocs/user/user_repository.dart';

class CommentItemWidget extends StatefulWidget {
  final Comment comment;
  final int level;
  final VoidCallback? onLike;

  const CommentItemWidget({
    Key? key,
    required this.comment,
    this.level = 0,
    this.onLike,
  }) : super(key: key);

  @override
  _CommentItemWidgetState createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<CommentItemWidget> {
  app_user.User? _user;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final user = await fetchUserById(widget.comment.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;
    final createdAtDateTime = widget.comment.createdAt.toDate();
    final formattedDate = timeago.format(createdAtDateTime, locale: 'en');

    String userName;
    String userAvatar;

    if (currentUserId == widget.comment.userId && currentUser != null) {
      userName = currentUser.displayName ?? 'User';
      userAvatar = currentUser.photoURL ?? 'https://via.placeholder.com/150';
    } else {
      userName = _user != null
          ? _user!.name ?? 'User'
          : _hasError
          ? 'Error loading user'
          : 'Loading...';
      userAvatar = _user != null && _user!.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
          ? _user!.avatarUrl!
          : 'https://via.placeholder.com/150';
    }

    return Padding(
      padding: EdgeInsets.only(left: 16.0 * widget.level, top: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(userAvatar),
            radius: 18,
            backgroundColor: Colors.grey[300],
            onBackgroundImageError: (exception, stackTrace) {
              print('Error loading avatar: $exception');
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.comment.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onLike,
                      child: const Text(
                        'Like',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    if (widget.comment.likeCount > 0) ...[
                      const SizedBox(width: 6),
                      Text('· ${widget.comment.likeCount}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}