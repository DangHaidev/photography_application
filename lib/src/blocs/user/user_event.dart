import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserInfoEvent extends UserEvent {
  final String userId;

  const FetchUserInfoEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchUserFollowingsEvent extends UserEvent {
  final String userId;

  const FetchUserFollowingsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}