import 'package:equatable/equatable.dart';

import '../../../core/domain/models/Message.dart';

abstract class MessageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendMessageEvent extends MessageEvent {
  final Message message;

  SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class LoadMessages extends MessageEvent {
  final String chatId;

  LoadMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class _MessagesUpdated extends MessageEvent {
  final List<Message> messages;

  _MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}
