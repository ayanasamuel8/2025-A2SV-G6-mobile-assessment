# Chat App

A Flutter application with secure authentication and real-time 1:1 chatting, built with clean architecture for maintainability and testability.

## Features

- Authentication
  - Email/password registration and login
  - Form validation and error messaging
  - Persistent session
- Chat
  - Chat list and message threads
  - Real-time updates powered by Dart Streams
  - Send, receive, and load message history
- UI/UX
  - Modern, responsive, and accessible design
  - Smooth navigation between auth and chat flows

## Screenshots

- Splash Screen  
  ![Splash screen](images/splash_screen.png)
- Login  
  ![Login page](images/login_page.png)
- Signup  
  ![Signup page](images/signup_page.png)
- Validation States  
  ![Validation errors](images/validation_errors.png)

## Getting Started

1. Clone the repository
   ```sh
   git clone https://github.com/ayanasamuel8/2025-A2SV-G6-mobile-assessment.git
   cd 2025-A2SV-G6-mobile-assessment/chat_app
   ```
2. Install dependencies
   ```sh
   flutter pub get
   ```
3. Run the app
   ```sh
   flutter run
   ```

## Tech Stack

- Flutter (Dart)
- State management: Provider
- Navigation: Flutter Navigator
- Real-time: Streams backed by your real-time backend (e.g., WebSocket/Firebase)

## Architecture

Clean architecture with clear separation of concerns:

- Domain Layer (lib/features/chat/domain)
  - Entities: ChatEntity, MessageEntity
  - Repositories: ChatRepository (abstracts chat operations)
  - Use Cases:
    - GetChatsUseCase
    - GetChatByIdUseCase
    - GetMessagesUseCase
    - InitiateChatUseCase
    - DeleteChatUseCase
- Data Layer (lib/features/chat/data)
  - datasources/ (remote/local)
  - models/ (DTOs)
  - repositories/ (implement ChatRepository)
- Presentation Layer (lib/features/chat/presentation)
  - Screens, widgets, and state holders for chat UI

## Real-Time Messaging

- Streams for live updates (new messages, updates)
- Example integration points:
  - watchMessages(chatId, token) -> Stream<List<MessageEntity>>
  - sendMessage(chatId, content, type, token) -> Either<Failure, MessageEntity>
- Resilience
  - Auto-reconnect
  - Local queue for unsent messages
  - Idempotent sends using client-generated IDs

## Testing

- Domain use cases: unit tests for get_chats_usecase, get_chat_by_id_usecase, get_messages_usecase, initiate_chat_usecase, delete_chat_usecase
- Repository contract tests: test/features/chat/domain/repositories/chat_repository_test.dart
- Stream tests for real-time flows with mock/fake sources
- Run tests
  ```sh
  flutter test
  ```

## Development

- Analyze and format
  ```sh
  flutter analyze
  ```

## Contributing

Issues and pull requests are welcome.

## License

MIT License
