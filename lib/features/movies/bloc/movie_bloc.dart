import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/movie_service.dart';
import 'movie_event.dart';
import 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  MovieBloc({required MovieService movieService})
      : _movieService = movieService,
        super(const MovieState()) {
    on<FetchMovies>(_onFetchMovies);
    on<FetchMoreMovies>(_onFetchMoreMovies);
    on<SearchMovies>(_onSearchMovies);
    on<ClearSearch>(_onClearSearch);
    on<AddRecentSearch>(_onAddRecentSearch);
  }

  final MovieService _movieService;

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<MovieState> emit,
  ) async {
    emit(state.copyWith(
      status: MovieStatus.loading,
      movies: [],
      currentPage: 0,
      hasReachedMax: false,
      isSearchMode: false,
      query: null,
    ));

    try {
      final response = await _movieService.getPopularMovies(page: 1);
      emit(state.copyWith(
        status: MovieStatus.success,
        movies: response.movies,
        currentPage: 1,
        hasReachedMax: !response.hasNextPage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MovieStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchMoreMovies(
    FetchMoreMovies event,
    Emitter<MovieState> emit,
  ) async {
    // Guard: don't load more if already at max or currently loading
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(status: MovieStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final response = state.isSearchMode && state.query != null
          ? await _movieService.searchMovies(
              query: state.query!,
              page: nextPage,
            )
          : await _movieService.getPopularMovies(page: nextPage);

      emit(state.copyWith(
        status: MovieStatus.success,
        // Key pattern: append new results to existing list
        movies: [...state.movies, ...response.movies],
        currentPage: nextPage,
        hasReachedMax: !response.hasNextPage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MovieStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<MovieState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const FetchMovies());
      return;
    }

    emit(state.copyWith(
      status: MovieStatus.loading,
      movies: [],
      currentPage: 0,
      hasReachedMax: false,
      isSearchMode: true,
      query: event.query,
    ));

    try {
      final response = await _movieService.searchMovies(
        query: event.query,
        page: 1,
      );
      emit(state.copyWith(
        status: MovieStatus.success,
        movies: response.movies,
        currentPage: 1,
        hasReachedMax: !response.hasNextPage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MovieStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<MovieState> emit) {
    add(const FetchMovies());
  }

  void _onAddRecentSearch(AddRecentSearch event, Emitter<MovieState> emit) {
    final updated = [
      event.query,
      ...state.recentSearches.where((s) => s != event.query),
    ].take(10).toList();
    emit(state.copyWith(recentSearches: updated));
  }
}
