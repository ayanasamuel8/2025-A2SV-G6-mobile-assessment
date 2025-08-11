part of 'user_search_bloc.dart';

sealed class UserSearchEvent extends Equatable {
  const UserSearchEvent();
  @override
  List<Object> get props => [];
}

/// Dispatched when the text in the search bar changes.
class SearchQueryChanged extends UserSearchEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object> get props => [query];
}

/// Dispatched to clear the search results and reset the state.
class ClearSearch extends UserSearchEvent {}
