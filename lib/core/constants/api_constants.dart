class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/w1280';
  static const String apiKey = 'YOUR_TMDB_API_KEY';

  // Endpoints
  static const String popularMovies = '/movie/popular';
  static const String movieDetail = '/movie';
  static const String searchMovies = '/search/movie';
  static const String movieCredits = '/credits';
  static const String similarMovies = '/similar';

  // Query params
  static const String paramApiKey = 'api_key';
  static const String paramPage = 'page';
  static const String paramQuery = 'query';

  static String movieDetailUrl(int id) => '$movieDetail/$id';
  static String movieCreditsUrl(int id) => '$movieDetail/$id$movieCredits';
  static String similarMoviesUrl(int id) => '$movieDetail/$id$similarMovies';
  static String posterUrl(String? path) =>
      path != null ? '$imageBaseUrl$path' : '';
  static String backdropUrl(String? path) =>
      path != null ? '$backdropBaseUrl$path' : '';
}
