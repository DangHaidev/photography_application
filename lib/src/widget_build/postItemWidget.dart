import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photography_application/src/views/profile/post_detail.dart' as post_detail;
import 'package:photography_application/src/widget_build/postImageCarousel.dart' as carousel;
import '../../core/domain/models/Post.dart';
import '../../core/domain/models/User.dart' as custom_user; // Alias to avoid conflict
import '../../core/utils/formatNumber.dart';
import '../../core/utils/formatTime.dart';
import '../blocs/follow/follow_bloc.dart';
import '../blocs/follow/follow_event.dart';
import '../blocs/follow/follow_state.dart';
import '../blocs/post/post_bloc.dart';
import '../blocs/post/post_event.dart';
import '../blocs/post/post_state.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../views/profile/profile_id.dart';
import 'commentSheet.dart';


class PostItemWidget extends StatefulWidget {
  final Post post;
  final bool isMyPost; // New parameter to indicate if this is the current user's post

  const PostItemWidget({
    Key? key,
    required this.post,
    this.isMyPost = false, // Default to false
  }) : super(key: key);

  @override
  _PostItemWidgetState createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  @override
  Widget build(BuildContext context) {
    debugPrint(
      'PostItemWidget: Đang xây dựng cho bài đăng ${widget.post.id}, userId: ${widget.post.userId}, isMyPost: ${widget.isMyPost}',
    );

    if (widget.post.userId.isEmpty) {
      debugPrint('PostItemWidget: userId rỗng cho bài đăng ${widget.post.id}');
      return _buildPost(context, {
        'name': 'Người dùng không xác định',
        'avatarUrl': 'https://picsum.photos/150',
      });
    }

    return BlocSelector<UserBloc, UserState, Map<String, dynamic>?>(
      selector: (state) {
        if (state is UserInfoLoadedState) {
          return state.users[widget.post.userId];
        }
        return null;
      },
      builder: (context, userData) {
        debugPrint(
          'PostItemWidget: Dữ liệu người dùng cho bài đăng ${widget.post.id}: $userData',
        );

        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) {
          debugPrint('PostItemWidget: Chưa đăng nhập, không thể theo dõi');
        } else {
          final followState = context.read<FollowBloc>().state;
          if (followState is FollowInitialState) {
            debugPrint('PostItemWidget: Kích hoạt FetchFollowingsEvent');
            context.read<FollowBloc>().add(
              FetchFollowingsEvent(userId: currentUserId),
            );
          }
        }

        if (userData == null) {
          debugPrint(
            'PostItemWidget: Chưa có dữ liệu người dùng cho userId: ${widget.post.userId}',
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UserBloc>().add(
              FetchUserInfoEvent(widget.post.userId),
            );
          });
          return const Center(child: CircularProgressIndicator());
        }

        return _buildPost(context, userData);
      },
    );
  }

  Widget _buildPost(BuildContext context, Map<String, dynamic> userData) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final postAuthor = custom_user.User.fromMap(widget.post.userId, userData);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSecondary,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final user = await context.read<PostBloc>().getUserByPost(widget.post.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(user: user),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          userData['avatarUrl'] ?? 'https://picsum.photos/150',
                        ),
                        onBackgroundImageError: (error, stackTrace) {
                          debugPrint('PostItemWidget: Lỗi tải avatar: $error');
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['name']?.toString() ?? 'Người dùng không xác định',
                            ),
                            Text(
                              formatTime(widget.post.createdAt.toDate()),
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            if (widget.isMyPost) // Hiển thị "My Post" nếu là bài đăng của current user
                              Text(
                                'My Post',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<FollowBloc, FollowState>(
                builder: (context, followState) {
                  bool isFollowing = false;
                  bool isLoading = false;

                  if (followState is FollowSuccessState) {
                    isFollowing = followState.followings.contains(widget.post.userId);
                  } else if (followState is FollowLoadingState) {
                    isLoading = true;
                  }

                  if (currentUserId == widget.post.userId || widget.isMyPost) {
                    return const SizedBox.shrink(); // Không hiển thị nút theo dõi nếu là bài đăng của mình
                  }

                  return ElevatedButton(
                    onPressed: (currentUserId == null || isLoading)
                        ? null
                        : () {
                      if (isFollowing) {
                        context.read<FollowBloc>().add(
                          UnfollowUserEvent(currentUserId, widget.post.userId),
                        );
                      } else {
                        context.read<FollowBloc>().add(
                          FollowUserEvent(currentUserId, widget.post.userId),
                        );
                      }
                      context.read<UserBloc>().add(FetchUserInfoEvent(widget.post.userId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(
                      isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.post.imageUrls.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => post_detail.PostDetailPage(
                      postId: widget.post.id,
                      postAuthor: postAuthor,
                    ),
                  ),
                );
              },
              child: carousel.PostImageCarousel(imageUrls: widget.post.imageUrls),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                  text: widget.post.caption.isNotEmpty ? widget.post.caption : 'Không có mô tả',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  BlocBuilder<PostBloc, PostState>(
                    builder: (context, postState) {
                      final isLiked = (postState is PostLoaded) ? postState.likedPosts.contains(widget.post.id) : false;
                      return GestureDetector(
                        onTap: () {
                          context.read<PostBloc>().add(LikePostEvent(widget.post.id));
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
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CommentSheet(postId: widget.post.id),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.comment_outlined, color: Colors.grey, size: 30),
                        const SizedBox(width: 6),
                        BlocBuilder<PostBloc, PostState>(
                          builder: (context, postState) {
                            final commentCount = (postState is PostLoaded) ? postState.commentCounts[widget.post.id] ?? 0 : 0;
                            return Text(
                              formatNumber(commentCount),
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  debugPrint("Nút tải xuống được nhấn cho bài đăng: ${widget.post.id}");
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