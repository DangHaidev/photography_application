import 'package:equatable/equatable.dart';

import '../../../core/domain/models/Chat.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load danh sách chat của user
class LoadChats extends ChatEvent {
  final String currentUserId;

  LoadChats(this.currentUserId);

  @override
  List<Object?> get props => [currentUserId];
}


class ChatsUpdated extends ChatEvent {
  final List<Chat> chats;

  ChatsUpdated(this.chats);

  @override
  List<Object?> get props => [chats];
}
// Nếu muốn có event khác như refresh, thêm chat, xóa chat,... thì thêm ở đây
