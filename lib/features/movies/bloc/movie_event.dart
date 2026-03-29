import 'package:equatable/equatable.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovies extends MovieEvent {
  const FetchMovies();
}

class FetchMoreMovies extends MovieEvent {
  const FetchMoreMovies();
}

class SearchMovies extends MovieEvent {
  const SearchMovies({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

class ClearSearch extends MovieEvent {
  const ClearSearch();
}

class AddRecentSearch extends MovieEvent {
  const AddRecentSearch({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}
