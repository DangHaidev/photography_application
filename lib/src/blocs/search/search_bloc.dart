import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photography_application/src/blocs/search/search_event.dart';
import 'package:photography_application/src/blocs/search/search_repository.dart';
import 'package:photography_application/src/blocs/search/search_state.dart';


class UserSearchBloc extends Bloc<UserSearchEvent, UserSearchState> {
  final UserRepository userRepository;


  UserSearchBloc({required this.userRepository}) : super(UserSearchInitial()) {
    on<SearchUsers>((event, emit) async {
  emit(UserSearchLoading());
  try {
    final users = await userRepository.searchUsersByEmail(event.query.toLowerCase());
    emit(UserSearchLoaded(users));
  } catch (e) {
    emit(UserSearchError("Lỗi khi tìm kiếm: $e"));
  }
});

  }
}
