import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photography_application/src/views/profile/post_detail.dart' as post_detail;
import 'package:photography_application/src/widget_build/postImageCarousel.dart' as carousel;
import '../../core/domain/models/Post.dart';
import '../../core/domain/models/User.dart' as custom_user;
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
  final bool isMyPost;

  const PostItemWidget({
    Key? key,
    required this.post,
    this.isMyPost = false,
  }) : super(key: key);

  @override
  _PostItemWidgetState createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('PostItemWidget: initState called for post ${widget.post.id}');
    if (mounted) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ));

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ));

      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    debugPrint('PostItemWidget: dispose called for post ${widget.post.id}');
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'PostItemWidget: Building for post ${widget.post.id}, userId: ${widget.post.userId}, isMyPost: ${widget.isMyPost}',
    );

    if (widget.post.userId.isEmpty) {
      debugPrint('PostItemWidget: Empty userId for post ${widget.post.id}');
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
          'PostItemWidget: User data for post ${widget.post.id}: $userData',
        );

        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId == null) {
          debugPrint('PostItemWidget: Not logged in, cannot follow');
        } else {
          final followState = context.read<FollowBloc>().state;
          if (followState is FollowInitialState) {
            debugPrint('PostItemWidget: Triggering FetchFollowingsEvent');
            context.read<FollowBloc>().add(
              FetchFollowingsEvent(userId: currentUserId),
            );
          }
        }

        if (userData == null) {
          debugPrint(
            'PostItemWidget: No user data for userId: ${widget.post.userId}',
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<UserBloc>().add(
                FetchUserInfoEvent(widget.post.userId),
              );
            }
          });
          return _buildLoadingSkeleton();
        }

        return _buildPost(context, userData);
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPost(BuildContext context, Map<String, dynamic> userData) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final postAuthor = custom_user.User.fromMap(widget.post.userId, userData);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController ?? AlwaysStoppedAnimation(1.0),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation ?? AlwaysStoppedAnimation(1.0),
          child: SlideTransition(
            position: _slideAnimation ?? AlwaysStoppedAnimation(Offset.zero),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, userData, currentUserId, isDarkMode),
                    if (widget.post.imageUrls.isNotEmpty)
                      _buildImageSection(context, postAuthor),
                    _buildCaptionSection(context, isDarkMode),
                    _buildActionSection(context, isDarkMode),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> userData,
      String? currentUserId, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final user =
                await context.read<PostBloc>().getUserByPost(widget.post.id);
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(user: user),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.isMyPost
                          ? LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      )
                          : null,
                      border: Border.all(
                        color: widget.isMyPost
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300],
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                          userData['avatarUrl'] ?? 'https://picsum.photos/150',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 30),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 30),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                userData['name']?.toString() ??
                                    'Người dùng không xác định',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.isMyPost) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'My Post',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatTime(widget.post.createdAt.toDate()),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFollowButton(context, currentUserId, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildFollowButton(
      BuildContext context, String? currentUserId, bool isDarkMode) {
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (context, followState) {
        bool isFollowing = false;
        bool isLoading = false;

        if (followState is FollowSuccessState) {
          isFollowing = followState.followings.contains(widget.post.userId);
        } else if (followState is FollowLoadingState) {
          isLoading = true;
        }

        if (currentUserId == widget.post.userId || widget.isMyPost) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: (currentUserId == null || isLoading)
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
                context
                    .read<UserBloc>()
                    .add(FetchUserInfoEvent(widget.post.userId));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isFollowing
                      ? null
                      : LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  color: isFollowing
                      ? (isDarkMode ? Colors.grey[700] : Colors.grey[200])
                      : null,
                  borderRadius: BorderRadius.circular(25),
                  border: isFollowing ? Border.all(color: Colors.grey[400]!) : null,
                ),
                child: isLoading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFollowing ? Colors.grey[600]! : Colors.white,
                    ),
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFollowing ? Icons.check : Icons.add,
                      size: 16,
                      color: isFollowing
                          ? (isDarkMode ? Colors.white70 : Colors.grey[700])
                          : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isFollowing
                            ? (isDarkMode
                            ? Colors.white70
                            : Colors.grey[700])
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(BuildContext context, custom_user.User postAuthor) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => post_detail.PostDetailPage(
                postId: widget.post.id,
                postAuthor: postAuthor,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: carousel.PostImageCarousel(imageUrls: widget.post.imageUrls),
        ),
      ),
    );
  }

  Widget _buildCaptionSection(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        widget.post.caption.isNotEmpty ? widget.post.caption : 'Không có mô tả',
        style: TextStyle(
          fontSize: 15,
          height: 1.4,
          color: isDarkMode ? Colors.white70 : Colors.black87,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildLikeButton(isDarkMode),
              const SizedBox(width: 24),
              _buildCommentButton(isDarkMode),
            ],
          ),
          _buildDownloadButton(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildLikeButton(bool isDarkMode) {
    return BlocBuilder<PostBloc, PostState>(
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLiked ? Colors.red.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatNumber(widget.post.likeCount),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CommentSheet(postId: widget.post.id),
          );
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<PostBloc, PostState>(
            builder: (context, postState) {
              final commentCount = (postState is PostLoaded)
                  ? postState.commentCounts[widget.post.id] ?? 0
                  : 0;
              return Text(
                formatNumber(commentCount),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        debugPrint("Download button pressed for post: ${widget.post.id}");
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.download_outlined,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
      ),
    );
  }
}