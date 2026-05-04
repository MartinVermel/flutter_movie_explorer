import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Debounce timer: delays the search API call by 300ms after the user stops
  // typing. This reduces unnecessary API calls and avoids rate-limiting.
  // Pattern: cancel previous timer on each keystroke, only fire when idle.
  Timer? _debounceTimer;
  static const _debounceDelay = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      context.read<MovieBloc>().add(SearchMovies(query: query));
      if (query.isNotEmpty) {
        context.read<MovieBloc>().add(AddRecentSearch(query: query));
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    context.read<MovieBloc>().add(const ClearSearch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search movies...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
        ),
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          // Show recent searches when field is empty
          if (!state.isSearchMode && state.recentSearches.isNotEmpty) {
            return _RecentSearches(
              searches: state.recentSearches,
              onSelect: (q) {
                _controller.text = q;
                context.read<MovieBloc>().add(SearchMovies(query: q));
              },
            );
          }

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isFailure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Search failed',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state.isSuccess && state.movies.isEmpty) {
            return _EmptySearchResult(query: state.query ?? '');
          }

          if (state.isSuccess) {
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.movies.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final movie = state.movies[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: ApiConstants.posterUrl(movie.posterPath),
                      width: 44,
                      height: 66,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 44,
                        height: 66,
                        color: AppTheme.cardBackground,
                        child: const Icon(Icons.movie, size: 24),
                      ),
                    ),
                  ),
                  title: Text(movie.title),
                  subtitle: Text(
                    '${movie.releaseYear} · ⭐ ${movie.voteAverage.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  onTap: () => context.push('/movie/${movie.id}'),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RecentSearches extends StatelessWidget {
  const _RecentSearches({required this.searches, required this.onSelect});

  final List<String> searches;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...searches.map((q) => ListTile(
              leading: const Icon(Icons.history, color: Colors.white38),
              title: Text(q),
              onTap: () => onSelect(q),
              trailing: const Icon(Icons.north_west,
                  size: 16, color: Colors.white38),
            )),
      ],
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
