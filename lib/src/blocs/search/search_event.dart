abstract class UserSearchEvent {}

class SearchUsers extends UserSearchEvent {
  final String query;
  SearchUsers(this.query);
}
