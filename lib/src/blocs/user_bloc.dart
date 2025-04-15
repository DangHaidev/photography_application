import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/domain/models/User.dart';

class UserBloc {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User> getUserById(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (doc.exists) {
        return User.fromMap(userId, doc.data()!);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      var query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data(); // Trả về dữ liệu của tài liệu đầu tiên
      } else {
        print("Không tìm thấy người dùng với userId: $userId");
        return null; // Trả về null nếu không tìm thấy tài liệu
      }
    } catch (e) {
      print("Lỗi khi truy vấn người dùng: $e");
      return null;
    }
  }

  Future<List<String>> getUserFollowings(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('follows')
              .where('followerId', isEqualTo: userId)
              .get();

      final followings =
          snapshot.docs.map((doc) => doc['followingId'] as String).toList();
      return followings;
    } catch (e) {
      print("Error fetching followings: $e");
      return [];
    }
  }
}
