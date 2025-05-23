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

  Future<void> _onFetchUserInfo(
      FetchUserInfoEvent event,
      Emitter<UserState> emit,
      ) async {
    debugPrint(
      'UserBloc: Đang xử lý FetchUserInfoEvent cho userId: ${event.userId}',
    );

    if (event.userId.isEmpty) {
      debugPrint('UserBloc: userId rỗng');
      emit(UserErrorState('userId không được rỗng'));
      return;
    }

    // Kiểm tra bộ nhớ đệm
    if (_userCache.containsKey(event.userId)) {
      debugPrint('UserBloc: Dữ liệu người dùng từ bộ nhớ đệm: ${event.userId}');
      emit(UserInfoLoadedState({..._userCache}));
      return;
    }

    // Kiểm tra yêu cầu đang chờ
    if (_pendingRequests.contains(event.userId)) {
      debugPrint(
        'UserBloc: Đã có yêu cầu đang chờ cho userId: ${event.userId}',
      );
      return;
    }

    // Thêm vào danh sách yêu cầu đang chờ
    _pendingRequests.add(event.userId);
    emit(UserLoadingState(event.userId));

    try {
      debugPrint('UserBloc: Truy vấn Firestore cho userId: ${event.userId}');
      final docSnapshot = await _firestore
          .collection('users')
          .doc(event.userId) // Truy vấn đến document theo userId
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        debugPrint('UserBloc: Dữ liệu người dùng: $userData');
        _userCache[event.userId] = Map<String, dynamic>.from(userData);
        debugPrint(
          'UserBloc: Đã tải dữ liệu người dùng: ${event.userId}, dữ liệu: $userData',
        );
        emit(UserInfoLoadedState({..._userCache}));
      } else {
        debugPrint('UserBloc: Không tìm thấy người dùng: ${event.userId}');
        emit(UserErrorState('Không tìm thấy người dùng'));
      }
    } catch (e) {
      debugPrint('UserBloc: Lỗi khi lấy userId: ${event.userId}, lỗi: $e');
      _pendingRequests.remove(event.userId);
      emit(UserErrorState('Lỗi khi truy vấn người dùng: $e'));
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