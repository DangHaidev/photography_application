import 'package:equatable/equatable.dart';

import '../../../core/domain/models/Chat.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Chat> chats;

  ChatLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error);

  @override
  List<Object?> get props => [error];
}
