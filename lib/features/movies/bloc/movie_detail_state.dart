import 'package:equatable/equatable.dart';
import '../models/movie_detail.dart';

enum MovieDetailStatus { initial, loading, success, failure }

class MovieDetailState extends Equatable {
  const MovieDetailState({
    this.status = MovieDetailStatus.initial,
    this.movieDetail,
    this.errorMessage,
  });

  final MovieDetailStatus status;
  final MovieDetail? movieDetail;
  final String? errorMessage;

  bool get isLoading => status == MovieDetailStatus.loading;
  bool get isSuccess => status == MovieDetailStatus.success;
  bool get isFailure => status == MovieDetailStatus.failure;

  MovieDetailState copyWith({
    MovieDetailStatus? status,
    MovieDetail? movieDetail,
    String? errorMessage,
  }) {
    return MovieDetailState(
      status: status ?? this.status,
      movieDetail: movieDetail ?? this.movieDetail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, movieDetail, errorMessage];
}
