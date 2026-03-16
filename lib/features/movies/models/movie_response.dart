import 'movie.dart';

class MovieResponse {
  const MovieResponse({
    required this.movies,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  final List<Movie> movies;
  final int page;
  final int totalPages;
  final int totalResults;

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
      movies: (json['results'] as List<dynamic>?)
              ?.map((e) => Movie.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      page: json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalResults: json['total_results'] as int? ?? 0,
    );
  }

  bool get hasNextPage => page < totalPages;
}
