import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/domain/models/Post.dart';
import '../../../core/domain/models/User.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Map<String, dynamic>> _userCache = {};
  final Set<String> _pendingRequests = {};

  UserBloc() : super(UserInitialState()) {
    debugPrint('UserBloc: Khởi tạo với các xử lý sự kiện');
    on<FetchUserInfoEvent>(_onFetchUserInfo);
    on<FetchUserFollowingsEvent>(_onFetchUserFollowings);
  }

  void clearCache() {
    _userCache.clear();
    _pendingRequests.clear();
    debugPrint('UserBloc: Đã xóa toàn bộ bộ nhớ đệm và yêu cầu đang chờ');
  }

  Future<void> _onFetchUserInfo(FetchUserInfoEvent event, Emitter<UserState> emit) async {
    if (event.userId.isEmpty) {
      debugPrint('UserBloc: userId rỗng');
      emit(UserErrorState('userId không được rỗng'));
      return;
    }

    // Check cache
    if (_userCache.containsKey(event.userId)) {
      debugPrint('UserBloc: Dữ liệu người dùng từ bộ nhớ đệm: ${event.userId}');
      // Only emit state if current state is not UserInfoLoadedState or data has changed
      if (state is! UserInfoLoadedState || (state as UserInfoLoadedState).users[event.userId] != _userCache[event.userId]) {
        emit(UserInfoLoadedState({..._userCache}));
      }
      return;
    }

    // Check pending requests
    if (_pendingRequests.contains(event.userId)) {
      debugPrint('UserBloc: Đã có yêu cầu đang chờ cho userId: ${event.userId}');
      return;
    }

    // Add to pending requests
    _pendingRequests.add(event.userId);
    emit(UserLoadingState(event.userId));

    try {
      debugPrint('UserBloc: Truy vấn Firestore cho userId: ${event.userId}');
      final docSnapshot = await _firestore
          .collection('users')
          .doc(event.userId)
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        debugPrint('UserBloc: Dữ liệu người dùng: $userData');
        _userCache[event.userId] = Map<String, dynamic>.from(userData);
        emit(UserInfoLoadedState({..._userCache}));
      } else {
        debugPrint('UserBloc: Không tìm thấy người dùng: ${event.userId}');
        emit(UserErrorState('Không tìm thấy người dùng'));
      }
    } catch (e) {
      debugPrint('UserBloc: Lỗi khi lấy userId: ${event.userId}, lỗi: $e');
      emit(UserErrorState('Lỗi khi truy vấn người dùng: $e'));
    } finally {
      _pendingRequests.remove(event.userId);
    }
  }

  Future<void> _onFetchUserFollowings(
      FetchUserFollowingsEvent event,
      Emitter<UserState> emit,
      ) async {
    debugPrint(
      'UserBloc: Đang lấy danh sách theo dõi cho userId: ${event.userId}',
    );
    emit(UserLoadingState(event.userId));
    try {
      debugPrint(
        'UserBloc: Truy vấn Firestore follows cho followerId: ${event.userId}',
      );
      final snapshot = await _firestore
          .collection('follows')
          .where('followerId', isEqualTo: event.userId)
          .get();

      final followings = snapshot.docs.map((doc) => doc['followingId'] as String).toList();
      debugPrint(
        'UserBloc: Đã tải danh sách theo dõi cho userId: ${event.userId}, số lượng: ${followings.length}',
      );
      emit(UserFollowingsLoadedState(followings));
    } catch (e) {
      debugPrint(
        'UserBloc: Lỗi khi lấy danh sách theo dõi cho userId: ${event.userId}, lỗi: $e',
      );
      emit(UserErrorState('Lỗi khi lấy danh sách người theo dõi: $e'));
    }
  }

}