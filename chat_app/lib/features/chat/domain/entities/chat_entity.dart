import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

class ChatEntity extends Equatable {
  final String id;
  final User sender;
  final User receiver;

  const ChatEntity({
    required this.id,
    required this.sender,
    required this.receiver,
  });

  @override
  List<Object?> get props => [id, sender, receiver];
}
