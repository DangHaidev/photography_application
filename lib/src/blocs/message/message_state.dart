import 'package:equatable/equatable.dart';
import '../../../core/domain/models/Message.dart';

abstract class MessageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessageLoadingState extends MessageState {}

class MessageLoadedState extends MessageState {
  final List<Message> messages;

  MessageLoadedState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageErrorState extends MessageState {
  final String error;

  MessageErrorState(this.error);

  @override
  List<Object?> get props => [error];
}
