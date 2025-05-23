import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/models/Message.dart' as models;

Future<models.Message?> fetchMessageById(String chatId, String messageId) async {
  try {
    final messageDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .get();

    if (messageDoc.exists) {
      final data = messageDoc.data()!;
      return models.Message.fromDocument(data, messageDoc.id);
    } else {
      print('Tin nhắn với ID $messageId không tồn tại trong chat $chatId');
      return null;
    }
  } catch (e) {
    print('Lỗi khi lấy tin nhắn $messageId trong chat $chatId: $e');
    return null;
  }
}

Future<models.Message?> fetchLatestMessage(String chatId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final messageDoc = querySnapshot.docs.first;
      final data = messageDoc.data();
      return models.Message.fromDocument(data, messageDoc.id);
    } else {
      print('Không tìm thấy tin nhắn nào trong chat $chatId');
      return null;
    }
  } catch (e) {
    print('Lỗi khi lấy tin nhắn mới nhất trong chat $chatId: $e');
    return null;
  }
}