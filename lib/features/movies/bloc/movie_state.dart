import 'package:equatable/equatable.dart';
import '../models/movie.dart';

enum MovieStatus { initial, loading, loadingMore, success, failure }

class MovieState extends Equatable {
  const MovieState({
    this.status = MovieStatus.initial,
    this.movies = const [],
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.errorMessage,
    this.query,
    this.recentSearches = const [],
    this.isSearchMode = false,
  });

  final MovieStatus status;
  final List<Movie> movies;
  final int currentPage;
  final bool hasReachedMax;
  final String? errorMessage;
  final String? query;
  final List<String> recentSearches;
  final bool isSearchMode;

  bool get isInitial => status == MovieStatus.initial;
  bool get isLoading => status == MovieStatus.loading;
  bool get isLoadingMore => status == MovieStatus.loadingMore;
  bool get isSuccess => status == MovieStatus.success;
  bool get isFailure => status == MovieStatus.failure;

  MovieState copyWith({
    MovieStatus? status,
    List<Movie>? movies,
    int? currentPage,
    bool? hasReachedMax,
    String? errorMessage,
    String? query,
    List<String>? recentSearches,
    bool? isSearchMode,
  }) {
    return MovieState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      recentSearches: recentSearches ?? this.recentSearches,
      isSearchMode: isSearchMode ?? this.isSearchMode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        movies,
        currentPage,
        hasReachedMax,
        errorMessage,
        query,
        recentSearches,
        isSearchMode,
      ];
}
