import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias cho FirebaseAuth
import '../../../core/domain/models/User.dart' as models; // Alias cho User tùy chỉnh

Future<models.User?> fetchUserById(String userId) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return models.User.fromMap(doc.id, data); // Sử dụng models.User
    } else {
      return null; // Trả về null nếu người dùng không tồn tại
    }
  } catch (e) {
    print('Lỗi khi lấy user: $e');
    return null; // Trả về null trong trường hợp có lỗi
  }
}

Future<models.User?> getOtherUser(List<String> userIds) async {
  // Lấy currentUserId từ FirebaseAuth
  final String? currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid; // Sử dụng firebase_auth

  // Kiểm tra nếu currentUserId tồn tại và danh sách userIds không rỗng
  if (currentUserId != null && userIds.isNotEmpty) {
    // Tìm id đầu tiên trong danh sách userIds mà không phải là currentUserId
    final otherUserId = userIds.firstWhere(
          (id) => id != currentUserId,
      orElse: () => '', // Trả về chuỗi rỗng nếu không tìm thấy
    );

    // Nếu tìm thấy otherUserId, gọi fetchUserById
    if (otherUserId.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
        if (doc.exists) {
          final data = doc.data()!;
          return models.User.fromMap(doc.id, data); // Sử dụng models.User
        }
      } catch (e) {
        print('Lỗi khi lấy thông tin user: $e');
        return null;
      }
    }
  }
  return null; // Trả về null nếu currentUserId không tồn tại, danh sách rỗng, hoặc không tìm thấy otherUserId
}