import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../features/movies/models/movie_response.dart';
import '../../features/movies/models/movie_detail.dart';

class MovieService {
  MovieService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      queryParameters: {ApiConstants.paramApiKey: ApiConstants.apiKey},
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => print(obj),
    ));
  }

  late final Dio _dio;

  Future<MovieResponse> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.popularMovies,
        queryParameters: {ApiConstants.paramPage: page},
      );
      return MovieResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MovieResponse> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchMovies,
        queryParameters: {
          ApiConstants.paramQuery: query,
          ApiConstants.paramPage: page,
        },
      );
      return MovieResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<MovieDetail> getMovieDetail(int id) async {
    try {
      final response = await _dio.get(
        ApiConstants.movieDetailUrl(id),
        queryParameters: {
          'append_to_response': 'credits,similar',
        },
      );
      return MovieDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out. Please check your internet.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Invalid API key. Please check your TMDB API key.');
        } else if (statusCode == 404) {
          return Exception('Movie not found.');
        }
        return Exception('Server error: $statusCode');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      default:
        return Exception('Something went wrong. Please try again.');
    }
  }
}
