import '../../../core/domain/models/Comment.dart';

abstract class CommentState {}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final Map<String, List<Comment>> comments;

  CommentLoaded(this.comments);
}

class CommentError extends CommentState {
  final String error;

  CommentError(this.error);
}
