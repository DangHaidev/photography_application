import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(
            userInfoMap,
            SetOptions(merge: true), // Cập nhật nếu tài liệu đã tồn tại
          );
    } catch (e) {
      throw Exception('Lỗi khi lưu thông tin người dùng: $e');
    }
  }
}
