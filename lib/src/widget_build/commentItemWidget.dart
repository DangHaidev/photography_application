import 'package:flutter/material.dart';
import '../../core/domain/models/Comment.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItemWidget extends StatelessWidget {
  final Comment comment;
  final int level;
  final VoidCallback? onReply;
  final VoidCallback? onViewReplies;
  final VoidCallback? onLike;

  const CommentItemWidget({
    Key? key,
    required this.comment,
    this.level = 0,
    this.onReply,
    this.onViewReplies,
    this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userAvatar =
        "https://i.pravatar.cc/150?img=${comment.userId.hashCode % 70}";
    final createdAtDateTime = comment.createdAt.toDate();
    final formattedDate = timeago.format(createdAtDateTime, locale: 'vi');

    return Padding(
      padding: EdgeInsets.only(left: 16.0 * level, top: 8.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(userAvatar), radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.userId.isNotEmpty
                            ? comment.userId
                            : 'Người dùng',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLike,
                      child: Text(
                        "Thích",
                        style: TextStyle(
                          color: comment.isLiked ? Colors.blue : Colors.grey,
                          fontWeight:
                              comment.isLiked
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onReply,
                      child: const Text(
                        "Trả lời",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (comment.likeCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        "· ${comment.likeCount}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                if (comment.replies != null && comment.replies!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onViewReplies,
                    child: Text(
                      "Xem ${comment.replies!.length} câu trả lời",
                      style: const TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
