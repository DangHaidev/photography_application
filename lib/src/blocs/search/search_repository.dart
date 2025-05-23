import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photography_application/core/domain/models/User.dart';


class UserRepository {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<List<User>> searchUsersByEmail(String query) async {
  final snapshot = await users
      .where('email', isGreaterThanOrEqualTo: query)
      .where('email', isLessThan: query + 'z')
      .get();

  return snapshot.docs
      .map((doc) => User.fromMap(doc.id, doc.data() as Map<String, dynamic>))
      .toList();
}

}
