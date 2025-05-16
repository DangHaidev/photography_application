import '../../../core/domain/models/Post.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final Set<String> likedPosts;
  final Map<String, int> commentCounts; // Map postId -> count

  PostLoaded({
    required this.posts,
    required this.likedPosts,
    required this.commentCounts,
  });
}

class PostError extends PostState {
  final String errorMessage;

  PostError(this.errorMessage);
}
