import 'package:flutter/material.dart';
import '../../blocs/homeScreen_bloc.dart';
import '../../core/domain/models/Comment.dart';
import 'CommentItemWidget.dart';

class CommentSheet extends StatelessWidget {
  final String postId;
  final HomescreenBloc bloc;

  const CommentSheet({Key? key, required this.postId, required this.bloc})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final comments = bloc.comments[postId] ?? [];
    final userAvatar = "https://i.pravatar.cc/150?img=1";

    if (!bloc.comments.containsKey(postId)) {
      bloc.loadComments(postId);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bình luận",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child:
                      comments.isEmpty
                          ? const Center(child: Text("Chưa có bình luận nào."))
                          : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 20,
                              ),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return CommentItemWidget(
                                  comment: comment,
                                  onReply:
                                      () => print(
                                        "Replying to ${comment.userId}",
                                      ),
                                  onViewReplies:
                                      () => print(
                                        "Viewing replies for ${comment.userId}",
                                      ),
                                  onLike:
                                      () =>
                                          bloc.likeComment(postId, comment.id),
                                );
                              },
                            ),
                          ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(userAvatar),
                        radius: 16,
                        onBackgroundImageError:
                            (_, __) => const Icon(Icons.error),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: bloc.commentController,
                                  decoration: const InputDecoration(
                                    hintText: "Viết bình luận...",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  final content =
                                      bloc.commentController.text.trim();
                                  if (content.isNotEmpty) {
                                    bloc.addComment(
                                      postId,
                                      content,
                                      'CurrentUser',
                                    );
                                    bloc.commentController.clear();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
