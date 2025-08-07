import '../../../auth/domain/entities/user.dart';

class ChatEntity {
  final String id;
  final User sender;
  final User receiver;

  ChatEntity({required this.id, required this.sender, required this.receiver});
}
