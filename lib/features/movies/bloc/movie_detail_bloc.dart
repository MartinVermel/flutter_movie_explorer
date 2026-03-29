import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/movie_service.dart';
import 'movie_detail_event.dart';
import 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  MovieDetailBloc({required MovieService movieService})
      : _movieService = movieService,
        super(const MovieDetailState()) {
    on<FetchMovieDetail>(_onFetchMovieDetail);
  }

  final MovieService _movieService;

  Future<void> _onFetchMovieDetail(
    FetchMovieDetail event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(state.copyWith(status: MovieDetailStatus.loading));

    try {
      // Single API call with append_to_response fetches credits and similar
      // in one request — reduces network round-trips
      final detail = await _movieService.getMovieDetail(event.movieId);
      emit(state.copyWith(
        status: MovieDetailStatus.success,
        movieDetail: detail,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MovieDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
