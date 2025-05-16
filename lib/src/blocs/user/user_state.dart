import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {
  final String userId;

  const UserLoadingState(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserInfoLoadedState extends UserState {
  final Map<String, Map<String, dynamic>> users;

  const UserInfoLoadedState(this.users);

  @override
  List<Object?> get props => [users];
}

class UserErrorState extends UserState {
  final String message;

  const UserErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class UserFollowingsLoadedState extends UserState {
  final List<String> followings;

  const UserFollowingsLoadedState(this.followings);

  @override
  List<Object?> get props => [followings];
}