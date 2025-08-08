import '../../../auth/data/models/user.dart';
import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.sender,
    required super.receiver,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      sender: UserModel.fromJson(json['sender']),
      receiver: UserModel.fromJson(json['receiver']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': (sender as UserModel).toJson(),
      'receiver': (receiver as UserModel).toJson(),
    };
  }

  ChatEntity toEntity() {
    return ChatEntity(id: id, sender: sender, receiver: receiver);
  }
}
