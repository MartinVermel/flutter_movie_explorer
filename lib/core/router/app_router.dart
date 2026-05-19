import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/movies/bloc/movie_bloc.dart';
import '../../features/movies/bloc/movie_detail_bloc.dart';
import '../../features/movies/screens/movie_list_screen.dart';
import '../../features/movies/screens/movie_detail_screen.dart';
import '../../features/movies/screens/search_screen.dart';
import '../../core/services/movie_service.dart';

/// go_router configuration.
///
/// We use a top-level GoRouter instance so it can be referenced from
/// MaterialApp.router without needing a provider. Each route uses a builder
/// that injects the required BLoC via BlocProvider, so each screen gets its
/// own BLoC lifecycle — no state leaks between navigations.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Page not found: ${state.uri}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => MovieBloc(movieService: MovieService()),
        child: const MovieListScreen(),
      ),
    ),
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        return BlocProvider(
          create: (_) => MovieDetailBloc(movieService: MovieService()),
          child: MovieDetailScreen(movieId: id),
        );
      },
    ),
    GoRoute(
      path: '/search',
      // Search reuses the parent MovieBloc via context.read in the parent route.
      // We pass a new BlocProvider here to allow search to live independently.
      builder: (context, state) => BlocProvider(
        create: (_) => MovieBloc(movieService: MovieService()),
        child: const SearchScreen(),
      ),
    ),
  ],
);
