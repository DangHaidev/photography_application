import '../../../core/domain/models/Post.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final Set<String> likedPosts;
  final Map<String, int> commentCounts;
  final bool hasMore;

  PostLoaded({
    required this.posts,
    required this.likedPosts,
    required this.commentCounts,
    required this.hasMore,
  });
}

class PostError extends PostState {
  final String errorMessage;

  PostError(this.errorMessage);
}