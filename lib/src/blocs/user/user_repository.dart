import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/models/User.dart';

Future<User?> fetchUserById(String userId) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      return User.fromMap(doc.id, data);
    } else {
      return null; // Trả về null nếu người dùng không tồn tại
    }
  } catch (e) {
    print('Lỗi khi lấy user: $e');
    return null; // Trả về null trong trường hợp có lỗi
  }
}