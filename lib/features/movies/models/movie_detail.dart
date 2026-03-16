import 'package:equatable/equatable.dart';
import 'movie.dart';

class Genre extends Equatable {
  const Genre({required this.id, required this.name});

  final int id;
  final String name;

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  @override
  List<Object> get props => [id, name];
}

class CastMember extends Equatable {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, character, profilePath];
}

class MovieDetail extends Equatable {
  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.runtime,
    required this.genres,
    required this.cast,
    required this.similarMovies,
    required this.tagline,
    required this.status,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;
  final int runtime;
  final List<Genre> genres;
  final List<CastMember> cast;
  final List<Movie> similarMovies;
  final String tagline;
  final String status;

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String? ?? '',
      runtime: json['runtime'] as int? ?? 0,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cast: (json['credits']?['cast'] as List<dynamic>?)
              ?.take(10)
              .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      similarMovies: (json['similar']?['results'] as List<dynamic>?)
              ?.map((e) => Movie.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tagline: json['tagline'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  String get runtimeFormatted {
    if (runtime == 0) return 'N/A';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  String get releaseYear =>
      releaseDate.isNotEmpty ? releaseDate.substring(0, 4) : 'N/A';

  @override
  List<Object?> get props => [
        id,
        title,
        overview,
        posterPath,
        backdropPath,
        voteAverage,
        releaseDate,
        runtime,
        genres,
        cast,
        similarMovies,
        tagline,
        status,
      ];
}
