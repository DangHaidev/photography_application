import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:photography_application/src/widget_build/postImageCarousel.dart';
import '../../core/domain/models/Post.dart';
import '../../core/domain/models/User.dart';
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
import '../views/profile/post_detail.dart';
import 'commentSheet.dart';

class PostItemWidget extends StatefulWidget {
  final Post post;

  const PostItemWidget({Key? key, required this.post}) : super(key: key);

  @override
  _PostItemWidgetState createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  bool _hasFetchedUser = false;
  bool _hasFetchedFollowings = false;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
    }

    if (widget.post.userId.isEmpty) {
      if (kDebugMode) {
      }
      return _buildPost(context, {
        'name': 'Unknown User',
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
        if (userData == null && !_hasFetchedUser) {
          if (kDebugMode) {
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UserBloc>().add(FetchUserInfoEvent(widget.post.userId));
          });
          _hasFetchedUser = true;
        }

        if (userData != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (kDebugMode) {
            }
          });
        }

        final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) {
          if (kDebugMode) {
          }
        } else if (!_hasFetchedFollowings) {
          final followState = context.read<FollowBloc>().state;
          if (followState is FollowInitialState) {
            if (kDebugMode) {
            }
            context.read<FollowBloc>().add(FetchFollowingsEvent(userId: currentUserId));
            _hasFetchedFollowings = true;
          }
        }

        if (userData == null) {
          if (kDebugMode) {
          }
          return const Center(child: CircularProgressIndicator());
        }

        return _buildPost(context, userData);
      },
    );
  }

  Widget _buildPost(BuildContext context, Map<String, dynamic> userData) {
    final currentUserId = auth.FirebaseAuth.instance.currentUser?.uid;
    // Create User object from userData for PostDetailPage
    final postAuthor = User.fromMap(widget.post.userId, userData);

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
                  if (kDebugMode) {
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['name']?.toString() ?? 'Unknown User',
                    ),
                    Text(
                      formatTime(widget.post.createdAt.toDate()),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              BlocBuilder<FollowBloc, FollowState>(
                buildWhen: (previous, current) {
                  if (previous is FollowSuccessState && current is FollowSuccessState) {
                    return previous.followings.contains(widget.post.userId) !=
                        current.followings.contains(widget.post.userId);
                  }
                  return previous.runtimeType != current.runtimeType;
                },
                builder: (context, followState) {
                  bool isFollowing = false;
                  bool isLoading = false;

                  if (followState is FollowSuccessState) {
                    isFollowing = followState.followings.contains(widget.post.userId);
                  } else if (followState is FollowLoadingState) {
                    isLoading = true;
                  }

                  if (currentUserId == widget.post.userId) {
                    return const SizedBox.shrink();
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
                      isFollowing ? 'Following' : 'Follow',
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
                if (kDebugMode) {
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailPage(
                      postId: widget.post.id,
                      postAuthor: postAuthor,
                    ),
                  ),
                );
              },
              child: PostImageCarousel(imageUrls: widget.post.imageUrls),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                  text: widget.post.caption.isNotEmpty ? widget.post.caption : 'No caption',
                ),
                // const TextSpan(
                //   text: " #LeganesBarça",
                //   style: TextStyle(color: Colors.blue),
                // ),
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
                    buildWhen: (previous, current) {
                      if (previous is PostLoaded && current is PostLoaded) {
                        return previous.likedPosts.contains(widget.post.id) !=
                            current.likedPosts.contains(widget.post.id);
                      }
                      return previous.runtimeType != current.runtimeType;
                    },
                    builder: (context, postState) {
                      final isLiked = (postState is PostLoaded)
                          ? postState.likedPosts.contains(widget.post.id)
                          : false;
                      return GestureDetector(
                        onTap: () {
                          context.read<PostBloc>().add(LikePostEvent(widget.post.id));
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
                              formatNumber(widget.post.likeCount),
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
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
                        const Icon(
                          FontAwesomeIcons.commentDots,
                          color: Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<PostBloc, PostState>(
                          buildWhen: (previous, current) {
                            if (previous is PostLoaded && current is PostLoaded) {
                              return (previous.commentCounts[widget.post.id] ?? 0) !=
                                  (current.commentCounts[widget.post.id] ?? 0);
                            }
                            return previous.runtimeType != current.runtimeType;
                          },
                          builder: (context, postState) {
                            final commentCount = (postState is PostLoaded)
                                ? postState.commentCounts[widget.post.id] ?? 0
                                : 0;
                            return Text(
                              formatNumber(commentCount),
                              style: const TextStyle(color: Colors.grey, fontSize: 16),
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
                  if (kDebugMode) {
                  }
                },
                child: const Icon(FontAwesomeIcons.download, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}