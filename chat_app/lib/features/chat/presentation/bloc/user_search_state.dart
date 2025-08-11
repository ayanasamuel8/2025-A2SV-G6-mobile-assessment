part of 'user_search_bloc.dart';

sealed class UserSearchState extends Equatable {
  const UserSearchState();
  @override
  List<Object> get props => [];
}

/// The initial state, nothing has been searched for yet.
final class UserSearchInitial extends UserSearchState {}

/// State when the BLoC is actively calling the API.
final class UserSearchLoading extends UserSearchState {}

/// State when the search was successful and returned a list of users.
final class UserSearchSuccess extends UserSearchState {
  final List<User> users;
  const UserSearchSuccess(this.users);
  @override
  List<Object> get props => [users];
}

/// State when the search failed.
final class UserSearchFailure extends UserSearchState {
  final String message;
  const UserSearchFailure(this.message);
  @override
  List<Object> get props => [message];
}
