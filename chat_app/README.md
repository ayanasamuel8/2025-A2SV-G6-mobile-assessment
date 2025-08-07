# chat_app

A Flutter project implementing a chat application with authentication.

## Features

- **User Authentication:** Secure login and registration screens.
- **Home Page:** Currently serves as a verification page for successful login. Will be updated with chat features in future releases.
- **Modern UI:** Clean and intuitive user interface for authentication flows.

## Screenshots

>### splash screen
![alt text](images/splash_screen.png)
>### Login Page
![alt text](images/login_page.png)
>### Signup Page
![alt text](images/signup_page.png)
>### Validation Errors
![alt text](images/validation_errors.png)

## Usage

1. **Clone the repository:**
   ```sh
   git clone https://github.com/ayanasamuel8/2025-A2SV-G6-mobile-assessment.git
   cd chat_app
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

4. **Authentication Flow:**
   - Launch the app.
   - Register a new account or log in with existing credentials.
   - Upon successful authentication, you are redirected to the Home Page, which currently verifies login status.
   - The Home Page will be enhanced with chat features in upcoming updates.

## Technical Overview

### Authentication

- **State Management:** [Provider](https://pub.dev/packages/provider) is used for managing authentication state.
- **Validation:** Form validation is implemented for email and password fields.
- **Navigation:** Uses Flutter's Navigator for routing between login, registration, and home screens.

### UI

- **Responsive Design:** Adapts to different screen sizes.
- **Material Design:** Follows Flutter’s Material guidelines for consistency and accessibility.

### Home Page

- **Current Purpose:** Acts as a placeholder to confirm successful authentication.
- **Future Plans:** Will display chat rooms, recent messages, and allow navigation to individual chats.

### Chat Feature Structure

The chat feature is organized using clean architecture principles, with clear separation between domain logic, data handling, and (future) presentation:

#### Domain Layer (`lib/features/chat/domain`)
- **Entities**
  - `ChatEntity`: Represents a chat between two users.
  - `MessageEntity`: Represents a message in a chat, including sender, content, and type.
- **Repositories**
  - `ChatRepository`: Abstracts chat operations such as fetching chats, messages, initiating and deleting chats.
- **Use Cases**
  - `GetChatsUseCase`: Fetches all chats for a user.
  - `GetChatByIdUsecase`: Fetches a specific chat by ID.
  - `GetMessagesUsecase`: Fetches messages for a chat.
  - `InitiateChatUseCase`: Starts a new chat with another user.
  - `DeleteChatUseCase`: Deletes a chat.

#### Data Layer (`lib/features/chat/data`)
- **(Placeholders for future implementation)**
  - `datasources/`, `models/`, `repositories/`: These folders are set up for data sources, data models, and repository implementations.

#### Presentation Layer (`lib/features/chat/presentation`)
- *(Currently empty, to be implemented as UI is developed.)*

---

### Chat Feature Testing

Unit tests are provided for all domain use cases and the repository interface, ensuring robust business logic:

#### Use Case Tests (`test/features/chat/domain/usecases`)
- Each use case (`get_chats_usecase`, `get_chat_by_id_usecase`, `get_messages_usecase`, `initiate_chat_usecase`, `delete_chat_usecase`) has a dedicated test file.
- Tests use mock repositories to verify correct behavior and error handling.

#### Repository Tests (`test/features/chat/domain/repositories`)
- chat_repository_test.dart: Tests the contract and expected behaviors of the `ChatRepository` interface.

---

### Example: How the Domain Layer Works

- **Entities** define the core data structures (`ChatEntity`, `MessageEntity`).
- **Repository** abstracts all chat-related operations, making the domain logic independent of data sources.
- **Use Cases** encapsulate specific actions (fetching chats, sending messages, etc.), making the business logic reusable and testable.

## Roadmap

- [x] Authentication (Login/Registration)
- [ ] Chat functionality (inprogress)
- [ ] User profiles
- [ ] Real-time messaging

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements.

## License

This project is licensed under the MIT License.

