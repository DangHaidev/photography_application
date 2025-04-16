import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'follow_event.dart';
import 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FollowBloc() : super(FollowInitialState()) {
    on<FollowUserEvent>(_onFollowUser);
    on<UnfollowUserEvent>(_onUnfollowUser);
    on<FetchFollowingsEvent>(_onFetchFollowings);
  }

  Future<void> _onFollowUser(
    FollowUserEvent event,
    Emitter<FollowState> emit,
  ) async {
    debugPrint(
      'FollowBloc: Processing FollowUserEvent for followerId: ${event.followerId}, followingId: ${event.followingId}',
    );
    emit(FollowLoadingState());
    try {
      await _firestore.collection('follows').add({
        'followerId': event.followerId,
        'followingId': event.followingId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('FollowBloc: Successfully followed ${event.followingId}');
      emit(
        FollowSuccessState(
          followings: await _fetchFollowings(event.followerId),
        ),
      );
    } catch (e) {
      debugPrint('FollowBloc: Error following user: $e');
      emit(FollowErrorState(errorMessage: "Failed to follow user: $e"));
    }
  }

  Future<void> _onUnfollowUser(
    UnfollowUserEvent event,
    Emitter<FollowState> emit,
  ) async {
    debugPrint(
      'FollowBloc: Processing UnfollowUserEvent for followerId: ${event.followerId}, followingId: ${event.followingId}',
    );
    emit(FollowLoadingState());
    try {
      final snapshot =
          await _firestore
              .collection('follows')
              .where('followerId', isEqualTo: event.followerId)
              .where('followingId', isEqualTo: event.followingId)
              .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('FollowBloc: Successfully unfollowed ${event.followingId}');
      emit(
        FollowSuccessState(
          followings: await _fetchFollowings(event.followerId),
        ),
      );
    } catch (e) {
      debugPrint('FollowBloc: Error unfollowing user: $e');
      emit(FollowErrorState(errorMessage: "Failed to unfollow user: $e"));
    }
  }

  Future<void> _onFetchFollowings(
    FetchFollowingsEvent event,
    Emitter<FollowState> emit,
  ) async {
    debugPrint('FollowBloc: Fetching followings for userId: ${event.userId}');
    emit(FollowLoadingState());
    try {
      final followings = await _fetchFollowings(event.userId);
      debugPrint('FollowBloc: Fetched followings: $followings');
      emit(FollowSuccessState(followings: followings));
    } catch (e) {
      debugPrint('FollowBloc: Error fetching followings: $e');
      emit(FollowErrorState(errorMessage: "Failed to fetch followings: $e"));
    }
  }

  Future<List<String>> _fetchFollowings(String userId) async {
    final snapshot =
        await _firestore
            .collection('follows')
            .where('followerId', isEqualTo: userId)
            .get();
    return snapshot.docs.map((doc) => doc['followingId'] as String).toList();
  }
}
