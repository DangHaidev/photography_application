import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    on<UpdateUserStatsEvent>(_onUpdateUserStats);
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

    if (_userCache.containsKey(event.userId)) {
      emit(UserInfoLoadedState({..._userCache}));
      return;
    }

    if (_pendingRequests.contains(event.userId)) {
      debugPrint(
        'UserBloc: Đã có yêu cầu đang chờ cho userId: ${event.userId}',
      );
      return;
    }

    _pendingRequests.add(event.userId);
    emit(UserLoadingState(event.userId));

    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(event.userId)
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        _userCache[event.userId] = Map<String, dynamic>.from(userData);
        emit(UserInfoLoadedState({..._userCache}));
      } else {
        emit(UserErrorState('Không tìm thấy người dùng'));
      }
    } catch (e) {
      debugPrint('UserBloc: Lỗi khi lấy userId: ${event.userId}, lỗi: $e');
      _pendingRequests.remove(event.userId); // Sửa lỗi cú pháp
      emit(UserErrorState('Lỗi khi truy vấn người dùng: $e')); // Tách lệnh emit
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

  Future<void> _onUpdateUserStats(
      UpdateUserStatsEvent event,
      Emitter<UserState> emit,
      ) async {
    debugPrint(
      'UserBloc: Đang xử lý UpdateUserStatsEvent cho userId: ${event.userId}',
    );
    emit(UserLoadingState(event.userId));

    try {
      // Tính tổng bài đăng
      final postsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: event.userId)
          .get();
      final totalPosts = postsSnapshot.docs.length;

      // Tính tổng người theo dõi
      final followersSnapshot = await _firestore
          .collection('follows')
          .where('followingId', isEqualTo: event.userId)
          .get();
      final totalFollowers = followersSnapshot.docs.length;

      // Cập nhật tài liệu người dùng trong Firestore
      await _firestore.collection('users').doc(event.userId).update({
        'totalPosts': totalPosts,
        'totalFollowers': totalFollowers,
      });

      // Cập nhật bộ nhớ đệm
      if (_userCache.containsKey(event.userId)) {
        _userCache[event.userId]!['totalPosts'] = totalPosts;
        _userCache[event.userId]!['totalFollowers'] = totalFollowers;
      } else {
        final userDoc = await _firestore.collection('users').doc(event.userId).get();
        if (userDoc.exists) {
          _userCache[event.userId] = Map<String, dynamic>.from(userDoc.data()!);
        }
      }

      debugPrint(
        'UserBloc: Đã cập nhật số liệu cho userId: ${event.userId}, totalPosts: $totalPosts, totalFollowers: $totalFollowers',
      );
      emit(UserInfoLoadedState({..._userCache}));
    } catch (e) {
      debugPrint('UserBloc: Lỗi khi cập nhật số liệu: ${event.userId}, lỗi: $e');
      emit(UserErrorState('Lỗi khi cập nhật số liệu người dùng: $e'));
    }
  }
}