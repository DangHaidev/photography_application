import 'package:equatable/equatable.dart';
import '../../../core/domain/models/User.dart';

abstract class FollowState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FollowInitialState extends FollowState {}

class FollowLoadingState extends FollowState {}

class FollowSuccessState extends FollowState {
  final List<String> followings;
  final User? user; // Include User object with totalFollowers

  FollowSuccessState({required this.followings, this.user});

  @override
  List<Object?> get props => [followings, user];
}

class FollowErrorState extends FollowState {
  final String errorMessage;

  FollowErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}