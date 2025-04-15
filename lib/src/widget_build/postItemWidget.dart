import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/domain/models/Post.dart';
import '../../core/utils/formatTime.dart';
import '../blocs/homeScreen_bloc.dart';
import '../blocs/user_bloc.dart';
import 'commentSheet.dart';

class PostItemWidget extends StatefulWidget {
  final Post post;
  final HomescreenBloc bloc;
  final UserBloc userBloc;

  const PostItemWidget({
    Key? key,
    required this.post,
    required this.bloc,
    required this.userBloc,
  }) : super(key: key);

  @override
  _PostItemWidgetState createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await widget.userBloc.getUserInfo(widget.post.userId);
      setState(() {
        userData = data;
        isLoading = false;
        hasError = data == null;
      });
    } catch (e) {
      print("Lỗi khi tải user ${widget.post.userId}: $e");
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  String formatNumber(int number) {
    if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(number % 1000 >= 100 ? 0 : 1)}K";
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        widget.post.imageUrl.isNotEmpty ? widget.post.imageUrl : null;
    final isLiked = widget.bloc.likedPosts.contains(widget.post.id);
    final commentCount = widget.bloc.commentCounts[widget.post.id] ?? 0;
    final createdAtDateTime = widget.post.createdAt.toDate();
    final minutesAgo =
        DateTime.now().difference(createdAtDateTime).inMinutes.abs();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info with timestamp and Follow button
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError || userData == null
              ? const ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage('https://picsum.photos/150'),
                ),
                title: Text('Người dùng không tồn tại'),
              )
              : Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      userData!['avatarUrl'] ?? 'https://picsum.photos/150',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userData!['name']?.toString() ?? 'Unknown'),
                        Text(
                          formatTime(createdAtDateTime), // Thời gian đăng bài
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print(
                        "Follow button pressed for user ${widget.post.userId}",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Follow', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),

          const SizedBox(height: 12),
          // Post image
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 220,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    height: 200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget: (context, url, error) {
                debugPrint("Image load error for URL '$url': $error");
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text(
                      'Không tìm thấy ảnh',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 12),
          // Post caption
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                  text:
                      widget.post.caption.isNotEmpty
                          ? widget.post.caption
                          : 'Không có mô tả',
                ),
                const TextSpan(
                  text: " #LeganesBarça",
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          // Interactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Like and Comment buttons
              Row(
                children: [
                  // Like button
                  GestureDetector(
                    onTap: () {
                      widget.bloc.likePost(widget.post.id);
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatNumber(widget.post.likeCount),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12), // Khoảng cách giữa các icon
                  // Comment button
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (context) => CommentSheet(
                              postId: widget.post.id,
                              bloc: widget.bloc,
                            ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.comment_outlined,
                          color: Colors.grey,
                          size: 30,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatNumber(commentCount),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Right side: Download icon
              GestureDetector(
                onTap: () {
                  print("Download icon pressed for post: ${widget.post.id}");
                  // Add your download logic here
                },
                child: const Icon(Icons.download, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
