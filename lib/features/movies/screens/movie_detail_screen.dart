import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../bloc/movie_detail_bloc.dart';
import '../bloc/movie_detail_event.dart';
import '../bloc/movie_detail_state.dart';
import '../models/movie_detail.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/star_rating.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<MovieDetailBloc>()
        .add(FetchMovieDetail(movieId: widget.movieId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const _DetailSkeleton();
          }

          if (state.isFailure) {
            return _ErrorView(
              message: state.errorMessage ?? 'Failed to load movie',
              onBack: () => context.pop(),
            );
          }

          if (state.isSuccess && state.movieDetail != null) {
            return _DetailContent(detail: state.movieDetail!);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _BackdropAppBar(detail: detail),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PosterRow(detail: detail),
                const SizedBox(height: 16),
                if (detail.tagline.isNotEmpty) ...[
                  Text(
                    '"${detail.tagline}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.accentColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(detail.overview,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                if (detail.genres.isNotEmpty) ...[
                  _GenreChips(genres: detail.genres),
                  const SizedBox(height: 20),
                ],
                if (detail.cast.isNotEmpty) ...[
                  Text('Cast', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  _CastChips(cast: detail.cast),
                  const SizedBox(height: 20),
                ],
                if (detail.similarMovies.isNotEmpty) ...[
                  Text('Similar Movies',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  _SimilarMoviesList(movies: detail.similarMovies),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BackdropAppBar extends StatelessWidget {
  const _BackdropAppBar({required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: ApiConstants.backdropUrl(detail.backdropPath),
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: AppTheme.primaryColor),
            ),
            // Frosted glass effect using BackdropFilter + ImageFilter.blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero animation: tag matches the one set in MovieCard
        Hero(
          tag: 'movie-poster-${detail.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: ApiConstants.posterUrl(detail.posterPath),
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${detail.releaseYear} · ${detail.runtimeFormatted}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  StarRating(rating: detail.voteAverage),
                  const SizedBox(width: 8),
                  Text(
                    detail.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppTheme.ratingColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(detail.status),
                backgroundColor: AppTheme.primaryColor,
                labelStyle: const TextStyle(color: AppTheme.accentColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenreChips extends StatelessWidget {
  const _GenreChips({required this.genres});

  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: genres
          .map((g) => Chip(
                label: Text(g.name),
                backgroundColor: AppTheme.accentColor.withOpacity(0.15),
                side: const BorderSide(color: AppTheme.accentColor, width: 0.5),
              ))
          .toList(),
    );
  }
}

class _CastChips extends StatelessWidget {
  const _CastChips({required this.cast});

  final List<CastMember> cast;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: cast
          .map((c) => Chip(
                label: Text('${c.name} as ${c.character}'),
                backgroundColor: AppTheme.cardBackground,
              ))
          .toList(),
    );
  }
}

class _SimilarMoviesList extends StatelessWidget {
  const _SimilarMoviesList({required this.movies});

  final movies;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () => context.push('/movie/${movie.id}'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: ApiConstants.posterUrl(movie.posterPath),
                width: 100,
                height: 160,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  color: AppTheme.cardBackground,
                  child: const Icon(Icons.movie, color: Colors.white38),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onBack, child: const Text('Go Back')),
        ],
      ),
    );
  }
}
