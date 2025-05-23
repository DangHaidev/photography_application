import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/models/Chat.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _chatsSubscription;

  ChatBloc() : super(ChatLoading()) {
    on<LoadChats>(_onLoadChats);
    on<ChatsUpdated>(_onChatsUpdated);
  }

  Future<void> _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    print('ChatBloc: Loading chats for user ${event.currentUserId}');
    emit(ChatLoading());

    try {
      // Cancel any existing subscription
      await _chatsSubscription?.cancel();

      // Query chats where userIds contains currentUserId
      _chatsSubscription = firestore
          .collection('chats')
          .where('userIds', arrayContains: event.currentUserId)
          .snapshots()
          .listen((snapshot) async {
        print('ChatBloc: Snapshot received with ${snapshot.docs.length} docs');

        // Process chats and fetch last message timestamps
        final chatsWithTimestamps = <Map<String, dynamic>>[];
        for (var doc in snapshot.docs) {
          final chat = Chat.fromMap(doc.data() as Map<String, dynamic>, doc.id);

          // Validate userIds (optional: enforce exactly 2 users)
          if (chat.userIds.length != 2) {
            print('ChatBloc: Skipping chat ${chat.chatId} with invalid userIds count: ${chat.userIds.length}');
            continue; // Skip chats that don't have exactly 2 users
          }

          // Fetch timestamp for last message
          DateTime? lastMessageTime;
          if (chat.lastMessageId != null) {
            try {
              final messageDoc = await firestore
                  .collection('chats')
                  .doc(chat.chatId)
                  .collection('messages')
                  .doc(chat.lastMessageId)
                  .get();
              if (messageDoc.exists) {
                final data = messageDoc.data() as Map<String, dynamic>;
                lastMessageTime = (data['timestamp'] as Timestamp?)?.toDate();
              }
            } catch (e) {
              print('ChatBloc: Error fetching message ${chat.lastMessageId} for chat ${chat.chatId}: $e');
            }
          }
          chatsWithTimestamps.add({
            'chat': chat,
            'lastMessageTime': lastMessageTime ?? DateTime(0),
          });
        }

        // Sort chats by last message time (newest first)
        chatsWithTimestamps.sort((a, b) => b['lastMessageTime'].compareTo(a['lastMessageTime']));
        final sortedChats = chatsWithTimestamps.map((e) => e['chat'] as Chat).toList();

        print('ChatBloc: Dispatching ChatsUpdated event with ${sortedChats.length} chats');
        add(ChatsUpdated(sortedChats));
      });
    } catch (e) {
      print('ChatBloc: Error $e');
      emit(ChatError(e.toString()));
    }
  }

  void _onChatsUpdated(ChatsUpdated event, Emitter<ChatState> emit) {
    print('ChatBloc: _onChatsUpdated called with ${event.chats.length} chats');
    emit(ChatLoaded(event.chats));
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}