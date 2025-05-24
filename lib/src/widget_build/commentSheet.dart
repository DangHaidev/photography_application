import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/domain/models/Comment.dart';
import '../../core/domain/models/User.dart' as app_user;
import '../blocs/comment/comment_bloc.dart';
import '../blocs/comment/comment_event.dart';
import '../blocs/comment/comment_state.dart';
import '../views/profile/profile_id.dart';
import 'CommentItemWidget.dart';
import '../blocs/user/user_repository.dart';

class CommentSheet extends StatefulWidget {
  final String postId;

  const CommentSheet({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  app_user.User? _currentUser;
  bool _isUserLoading = true;
  bool _hasUserError = false;

  @override
  void initState() {
    super.initState();
    // Tải comment khi widget khởi tạo
    context.read<CommentBloc>().add(FetchCommentsEvent(widget.postId));
    // Tải thông tin người dùng hiện tại
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isUserLoading = false;
          _hasUserError = true;
        });
        return;
      }

      final user = await fetchUserById(currentUser.uid);
      setState(() {
        _currentUser = user;
        _isUserLoading = false;
      });
    } catch (e) {
      print('Error fetching current user: $e');
      setState(() {
        _hasUserError = true;
        _isUserLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin userId và avatar từ Firebase Authentication
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid ?? 'Unknown User';
    final userAvatar =
        currentUser?.photoURL ?? "https://i.pravatar.cc/150?img=${userId.hashCode % 70}";

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Thanh kéo
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Tiêu đề và nút đóng
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Comments",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Màu đen cho tiêu đề
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              // Danh sách bình luận
              Expanded(
                child: BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    if (state is CommentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CommentLoaded &&
                        state.comments.containsKey(widget.postId)) {
                      final comments = state.comments[widget.postId]!;
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return CommentItemWidget(
                            comment: comment,
                            onReply: () => print("Replying to ${comment.userId}"),
                            onViewReplies: () => print("Viewing replies for ${comment.userId}"),
                            onLike: () {
                              context.read<CommentBloc>().add(
                                LikeCommentEvent(
                                  postId: widget.postId,
                                  commentId: comment.id,
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          "No comments",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      );
                    }
                  },
                ),
              ),
              // Input bình luận
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_currentUser != null && !_isUserLoading && !_hasUserError) {
                          print("Navigating to profile with user: $_currentUser");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(user: _currentUser),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không thể xem hồ sơ người dùng')),
                          );
                        }
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(userAvatar),
                        radius: 18,
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Error loading avatar: $exception');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(color: Colors.black), // Màu chữ nhập
                                decoration: const InputDecoration(
                                  hintText: "Write a comment...",
                                  hintStyle: TextStyle(color: Colors.black54), // Màu gợi ý đen
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Colors.blue[600],
                                size: 24,
                              ),
                              onPressed: () {
                                final content = _controller.text.trim();
                                if (content.isNotEmpty) {
                                  context.read<CommentBloc>().add(
                                    AddCommentEvent(
                                      postId: widget.postId,
                                      content: content,
                                      userId: userId,
                                    ),
                                  );
                                  _controller.clear();
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
        );
      },
    );
  }
}