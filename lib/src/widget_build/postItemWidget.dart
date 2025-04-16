import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/domain/models/Post.dart';
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
import 'commentSheet.dart';

class PostItemWidget extends StatefulWidget {
  final Post post;

  const PostItemWidget({Key? key, required this.post}) : super(key: key);

  @override
  _PostItemWidgetState createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  @override
  Widget build(BuildContext context) {
    debugPrint(
      'PostItemWidget: Đang xây dựng cho bài đăng ${widget.post.id}, userId: ${widget.post.userId}',
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

        // Kích hoạt FollowBloc với user124 tạm thời
        final followState = context.read<FollowBloc>().state;
        if (followState is FollowInitialState) {
          debugPrint('PostItemWidget: Kích hoạt FetchFollowingsEvent');
          const currentUserId = 'user124'; // Sử dụng user124 tạm thời
          context.read<FollowBloc>().add(
            FetchFollowingsEvent(userId: currentUserId),
          );
        }

        if (userData == null) {
          debugPrint(
            'PostItemWidget: Chưa có dữ liệu người dùng cho userId: ${widget.post.userId}',
          );
          // Kích hoạt FetchUserInfoEvent nếu chưa có dữ liệu (dự phòng)
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
          Row(
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
                      userData['name']?.toString() ??
                          'Người dùng không xác định',
                    ),
                    Text(
                      formatTime(widget.post.createdAt.toDate()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              BlocBuilder<FollowBloc, FollowState>(
                builder: (context, followState) {
                  debugPrint(
                    'PostItemWidget: Trạng thái FollowBloc cho bài đăng ${widget.post.id}: $followState',
                  );
                  bool isFollowing = false;
                  bool isLoading = false;

                  if (followState is FollowSuccessState) {
                    isFollowing = followState.followings.contains(
                      widget.post.userId,
                    );
                  } else if (followState is FollowErrorState) {
                    debugPrint(
                      'PostItemWidget: FollowErrorState - ${followState.errorMessage}',
                    );
                  } else if (followState is FollowLoadingState) {
                    isLoading = true;
                  }

                  return ElevatedButton(
                    onPressed:
                        isLoading || isFollowing
                            ? null
                            : () {
                              debugPrint(
                                'PostItemWidget: Thêm FollowUserEvent cho followerId: user124, followingId: ${widget.post.userId}',
                              );
                              const currentUserId =
                                  'user124'; // Sử dụng user124 tạm thời
                              context.read<FollowBloc>().add(
                                FollowUserEvent(
                                  followerId: currentUserId,
                                  followingId: widget.post.userId,
                                ),
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child:
                        isLoading
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
          if (widget.post.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 220,
              memCacheHeight: 220,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    height: 220,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget: (context, url, error) {
                debugPrint(
                  'PostItemWidget: Lỗi tải ảnh cho ${widget.post.imageUrl}: $error',
                );
                return Container(
                  width: double.infinity,
                  height: 220,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  BlocBuilder<PostBloc, PostState>(
                    builder: (context, postState) {
                      debugPrint(
                        'PostItemWidget: Trạng thái PostBloc cho bài đăng ${widget.post.id}: $postState',
                      );
                      final isLiked =
                          (postState is PostLoaded)
                              ? postState.likedPosts.contains(widget.post.id)
                              : false;
                      return GestureDetector(
                        onTap: () {
                          context.read<PostBloc>().add(
                            LikePostEvent(widget.post.id),
                          );
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
                        builder:
                            (context) => CommentSheet(postId: widget.post.id),
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
                        BlocBuilder<PostBloc, PostState>(
                          builder: (context, postState) {
                            debugPrint(
                              'PostItemWidget: Trạng thái số bình luận cho bài đăng ${widget.post.id}: $postState',
                            );
                            final commentCount =
                                (postState is PostLoaded)
                                    ? postState.commentCounts[widget.post.id] ??
                                        0
                                    : 0;
                            return Text(
                              formatNumber(commentCount),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
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
                  debugPrint(
                    "Nút tải xuống được nhấn cho bài đăng: ${widget.post.id}",
                  );
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
