import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/search_users_usecase.dart';

part 'user_search_event.dart';
part 'user_search_state.dart';

// Helper for the debounce transformer
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final SearchUsersUseCase _searchUsersUseCase;

  UserSearchBloc({required SearchUsersUseCase searchUsersUseCase})
    : _searchUsersUseCase = searchUsersUseCase,
      super(UserSearchInitial()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      // This is crucial: it prevents an API call on every keystroke.
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<UserSearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      return emit(UserSearchInitial());
    }
    emit(UserSearchLoading());
    final result = await _searchUsersUseCase(event.query);
    result.fold(
      (failure) => emit(const UserSearchFailure('Failed to search users.')),
      (users) => emit(UserSearchSuccess(users)),
    );
  }

  void _onClearSearch(ClearSearch event, Emitter<UserSearchState> emit) {
    emit(UserSearchInitial());
  }
}
