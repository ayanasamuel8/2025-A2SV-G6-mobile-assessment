// Mock users
import '../../features/auth/domain/entities/user.dart';
import '../../features/chat/domain/entities/chat_entity.dart';

const mockUser1 = User(id: 'user1', name: 'Alice', email: 'alice@example.com');

const mockUser2 = User(id: 'user2', name: 'Bob', email: 'bob@example.com');

const mockUser3 = User(
  id: 'user3',
  name: 'Charlie',
  email: 'charlie@example.com',
);

// Mock chats
const mockChats = [
  ChatEntity(id: 'chat1', user1: mockUser1, user2: mockUser2),
  ChatEntity(id: 'chat2', user1: mockUser1, user2: mockUser3),
  ChatEntity(id: 'chat3', user1: mockUser2, user2: mockUser3),
];
