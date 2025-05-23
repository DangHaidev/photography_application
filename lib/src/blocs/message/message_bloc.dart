import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/models/Message.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  MessageBloc() : super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<SendMessageEvent>(_onSendMessage);
  }

  void _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) {
    emit(MessageLoadingState());

    // Cancel previous subscription if any
    _messagesSubscription?.cancel();

    _messagesSubscription = _firestore
        .collection('chats')
        .doc(event.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs
          .map((doc) => Message.fromDocument(doc.data(), doc.id))
          .toList();

      add(_MessagesUpdated(messages));
    }, onError: (error) {
      emit(MessageErrorState(error.toString()));
    });
  }

  void _onMessagesUpdated(_MessagesUpdated event, Emitter<MessageState> emit) {
    emit(MessageLoadedState(event.messages));
  }

  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<MessageState> emit,
      ) async {
    try {
      // Gửi message vào collection con theo chatId
      final messageRef = _firestore
          .collection('chats')
          .doc(event.message.chatId)
          .collection('messages')
          .doc();

      await messageRef.set(event.message.toMap());
    } catch (e) {
      emit(MessageErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}

// Đảm bảo event _MessagesUpdated được khai báo trong message_event.dart như private event
class _MessagesUpdated extends MessageEvent {
  final List<Message> messages;

  _MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}
