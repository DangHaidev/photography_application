import '../../../core/domain/models/Post.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts; // General posts
  final Set<String> likedPosts; // IDs of liked posts
  final Map<String, int> commentCounts; // Comment counts
  final List<Post> userPosts; // User-specific posts

  PostLoaded({
    required this.posts,
    required this.likedPosts,
    required this.commentCounts,
    required this.userPosts,
  });
}

class PostError extends PostState {
  final String errorMessage;

  PostError(this.errorMessage);
}