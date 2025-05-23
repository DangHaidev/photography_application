import 'package:photography_application/core/domain/models/User.dart';


abstract class UserSearchState {}

class UserSearchInitial extends UserSearchState {}

class UserSearchLoading extends UserSearchState {}

class UserSearchLoaded extends UserSearchState {
  final List<User> users;
  UserSearchLoaded(this.users);
}

class UserSearchError extends UserSearchState {
  final String message;
  UserSearchError(this.message);
}
