import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../blocs/homeScreen_bloc.dart';
import '../../core/domain/models/Post.dart';

class PostItemWidget extends StatelessWidget {
  final Post post;

  const PostItemWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userAvatar =
        "https://i.pravatar.cc/150?img=${post.userId.hashCode % 70}";
    final imageUrl = post.imageUrl.isNotEmpty ? post.imageUrl : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(userAvatar),
                radius: 20,
                onBackgroundImageError: (_, __) => const Icon(Icons.error),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  post.userId.isNotEmpty ? post.userId : 'Unknown User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(onPressed: () {}, child: const Text("Follow")),
            ],
          ),
          const SizedBox(height: 10),
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                placeholder:
                    (context, url) => const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                errorWidget: (context, url, error) {
                  debugPrint("Image load error for URL '$url': $error");
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Không tìm thấy ảnh',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Không có ảnh',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(post.caption.isNotEmpty ? post.caption : 'Không có mô tả'),
          const SizedBox(height: 5),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  context.read<HomescreenBloc>().likePost(post.id);
                },
                icon: const Icon(Icons.favorite_border),
              ),
              Text("${post.likeCount}"),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border),
              ),
              Text("${post.commentCount}"),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
            ],
          ),
        ],
      ),
    );
  }
}
