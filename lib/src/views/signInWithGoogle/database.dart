import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // Phương thức lưu thông tin người dùng vào Firestore
  Future<void> addUser(String uid, Map<String, dynamic> userInfoMap) async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // Nếu người dùng đã tồn tại, chỉ cập nhật các trường cần thiết
        await userDocRef.update({
          'name': userInfoMap['name'],
          'email': userInfoMap['email'],
          'avatarUrl': userInfoMap['avatarUrl'],
          'bio': userInfoMap['bio'] ?? '',
          // Không cập nhật totalFollowers, totalPosts, totalDownloadPosts
        });
      } else {
        // Nếu người dùng chưa tồn tại, tạo tài liệu mới
        await userDocRef.set(userInfoMap);
      }
    } catch (e) {
      print('Error saving user: $e');
      throw e;
    }
  }
}