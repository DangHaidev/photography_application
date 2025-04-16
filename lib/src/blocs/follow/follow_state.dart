abstract class FollowState {}

class FollowInitialState extends FollowState {}

class FollowLoadingState extends FollowState {}

class FollowSuccessState extends FollowState {
  final List<String> followings;

  FollowSuccessState({required this.followings});
}

class FollowErrorState extends FollowState {
  final String errorMessage;

  FollowErrorState({required this.errorMessage});
}
