import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_card_skeleton.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // PagingController drives the infinite_scroll_pagination package.
  // It tracks page keys and notifies listeners when new pages are available.
  final PagingController<int, Movie> _pagingController =
      PagingController(firstPageKey: 1);

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MovieBloc>().add(const FetchMovies());
    _pagingController.addPageRequestListener((_) {
      context.read<MovieBloc>().add(const FetchMoreMovies());
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎬 Movie Explorer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: BlocListener<MovieBloc, MovieState>(
        listener: (context, state) {
          // Sync BLoC state into the PagingController.
          // This bridge between BLoC and PagingController is the key design
          // choice: BLoC owns the data, PagingController owns the pagination UI.
          if (state.isSuccess) {
            if (state.currentPage == 1) {
              _pagingController.refresh();
            }
            if (state.hasReachedMax) {
              _pagingController.appendLastPage(state.movies);
            } else {
              _pagingController.appendPage(state.movies, state.currentPage + 1);
            }
          } else if (state.isFailure) {
            _pagingController.error = state.errorMessage;
          }
        },
        child: BlocBuilder<MovieBloc, MovieState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const MovieGridSkeleton();
            }

            if (state.isFailure && state.movies.isEmpty) {
              return _ErrorView(
                message: state.errorMessage ?? 'Something went wrong',
                onRetry: () =>
                    context.read<MovieBloc>().add(const FetchMovies()),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MovieBloc>().add(const FetchMovies());
              },
              child: PagedGridView<int, Movie>(
                pagingController: _pagingController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                builderDelegate: PagedChildBuilderDelegate<Movie>(
                  itemBuilder: (context, movie, index) => MovieCard(
                    movie: movie,
                    onTap: () => context.push('/movie/${movie.id}'),
                  ),
                  firstPageProgressIndicatorBuilder: (_) =>
                      const MovieGridSkeleton(),
                  newPageProgressIndicatorBuilder: (_) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (_) => const _EmptyView(),
                  firstPageErrorIndicatorBuilder: (context) => _ErrorView(
                    message: _pagingController.error?.toString() ?? 'Error',
                    onRetry: () => _pagingController.retryLastFailedRequest(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter, size: 64, color: Colors.white38),
          SizedBox(height: 16),
          Text('No movies found', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
