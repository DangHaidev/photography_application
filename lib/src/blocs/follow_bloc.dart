import 'package:flutter_bloc/flutter_bloc.dart';

// Event Definitions
abstract class FollowEvent {}

class FollowUserEvent extends FollowEvent {
  final String followerId;
  final String followingId;

  FollowUserEvent({required this.followerId, required this.followingId});
}

class UnfollowUserEvent extends FollowEvent {
  final String followerId;
  final String followingId;

  UnfollowUserEvent({required this.followerId, required this.followingId});
}

class FetchFollowingsEvent extends FollowEvent {
  final String userId;

  FetchFollowingsEvent({required this.userId});
}

// State Definitions
abstract class FollowState {}

class FollowInitialState extends FollowState {}

class FollowSuccessState extends FollowState {
  final List<String> followings;

  FollowSuccessState({required this.followings});
}

class FollowErrorState extends FollowState {
  final String errorMessage;

  FollowErrorState({required this.errorMessage});
}

// BLoC Logic
class FollowBloc extends Bloc<FollowEvent, FollowState> {
  // Assuming this is a mock data source
  final Map<String, List<String>> _followings = {};

  FollowBloc() : super(FollowInitialState());

  @override
  Stream<FollowState> mapEventToState(FollowEvent event) async* {
    if (event is FollowUserEvent) {
      try {
        _followUser(event.followerId, event.followingId);
        yield FollowSuccessState(followings: _followings[event.followerId]!);
      } catch (e) {
        yield FollowErrorState(errorMessage: "Failed to follow user.");
      }
    } else if (event is UnfollowUserEvent) {
      try {
        _unfollowUser(event.followerId, event.followingId);
        yield FollowSuccessState(followings: _followings[event.followerId]!);
      } catch (e) {
        yield FollowErrorState(errorMessage: "Failed to unfollow user.");
      }
    } else if (event is FetchFollowingsEvent) {
      try {
        final followings = _followings[event.userId] ?? [];
        yield FollowSuccessState(followings: followings);
      } catch (e) {
        yield FollowErrorState(errorMessage: "Failed to fetch followings.");
      }
    }
  }

  void _followUser(String followerId, String followingId) {
    if (_followings[followerId] == null) {
      _followings[followerId] = [];
    }

    if (!_followings[followerId]!.contains(followingId)) {
      _followings[followerId]!.add(followingId);
    }
  }

  void _unfollowUser(String followerId, String followingId) {
    if (_followings[followerId] != null) {
      _followings[followerId]!.remove(followingId);
    }
  }
}
