import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../blocs/homeScreen_bloc.dart';
import '../../core/domain/models/Post.dart';
import 'commentSheet.dart';

class PostItemWidget extends StatelessWidget {
  final Post post;

  const PostItemWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userAvatar =
        "https://i.pravatar.cc/150?img=${post.userId.hashCode % 70}";
    final imageUrl = post.imageUrl.isNotEmpty ? post.imageUrl : null;
    final bloc = context.watch<HomescreenBloc>();
    final isLiked = bloc.likedPosts.contains(post.id);
    final commentCount = bloc.commentCounts[post.id] ?? 0;

    final createdAtDateTime = post.createdAt.toDate();
    final minutesAgo =
        DateTime.now().difference(createdAtDateTime).inMinutes.abs();

    String formatNumber(int number) {
      if (number >= 1000000) {
        return "${(number / 1000000).toStringAsFixed(1)}M";
      } else if (number >= 1000) {
        return "${(number / 1000).toStringAsFixed(number % 1000 >= 100 ? 0 : 1)}K";
      }
      return number.toString();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + User info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userAvatar),
                  radius: 22,
                  onBackgroundImageError: (_, __) => const Icon(Icons.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userId.isNotEmpty
                            ? post.userId
                            : 'Người dùng ẩn danh',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$minutesAgo phút trước",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Image
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[200],
                        height: 220,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  errorWidget: (context, url, error) {
                    debugPrint("Image load error for URL '$url': $error");
                    return Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Text(
                          'Không thể tải ảnh',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            // Caption
            Text(
              post.caption.isNotEmpty ? post.caption : 'Không có mô tả',
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),

            const SizedBox(height: 12),

            // Interaction Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like
                GestureDetector(
                  onTap: () => context.read<HomescreenBloc>().likePost(post.id),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatNumber(post.likeCount),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                // Comment
                GestureDetector(
                  onTap: () {
                    final bloc = context.read<HomescreenBloc>();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CommentSheet(postId: post.id, bloc: bloc),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        formatNumber(commentCount),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                // Share
                GestureDetector(
                  onTap: () {
                    print("Chia sẻ bài viết: ${post.id}");
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.share_outlined, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("Chia sẻ", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
