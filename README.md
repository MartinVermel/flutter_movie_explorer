# 🎬 Flutter Movie Explorer

A movie browser app built to showcase Flutter architecture skills: BLoC state management, go_router navigation, shimmer loading, Hero animations, and infinite scroll pagination.

## Features

- **Popular Movies Grid** — Browse popular movies in a 2-column grid with infinite scroll
- **Movie Detail** — Full detail view with backdrop, cast chips, genre tags, rating stars, and similar movies
- **Search** — Debounced search (300ms) with recent search history stored in BLoC state
- **Shimmer Loading** — Animated skeleton placeholders while data loads
- **Hero Animation** — Smooth shared-element poster transition between list and detail
- **Offline Error States** — Graceful error messages with retry support

## Tech Stack

| Library | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^8.1.5 | State management (BLoC pattern) |
| `go_router` | ^14.2.7 | Declarative navigation |
| `dio` | ^5.4.3 | HTTP client with interceptors |
| `cached_network_image` | ^3.3.1 | Image caching |
| `shimmer` | ^3.0.0 | Skeleton loading animation |
| `infinite_scroll_pagination` | ^4.0.0 | Paginated list UI |
| `equatable` | ^2.0.5 | Value equality for BLoC states |

## Architecture

```
lib/
├── main.dart
├── core/
│   ├── constants/     # API endpoints and keys
│   ├── router/        # go_router configuration
│   ├── services/      # Dio-based API service
│   └── theme/         # Dark theme tokens
└── features/
    └── movies/
        ├── bloc/      # MovieBloc, MovieDetailBloc (events + states)
        ├── models/    # Movie, MovieDetail, CastMember (Equatable)
        ├── screens/   # MovieListScreen, MovieDetailScreen, SearchScreen
        └── widgets/   # MovieCard, MovieCardSkeleton, StarRating
```

## Setup

1. Clone the repo
2. Run `flutter pub get`
3. Get a free TMDB API key at [themoviedb.org](https://www.themoviedb.org/settings/api)
4. Replace `YOUR_TMDB_API_KEY` in `lib/core/constants/api_constants.dart`
5. Run `flutter run`

## Key Patterns Demonstrated

### BLoC Pattern
Events are dispatched by the UI; the Bloc transforms them into new states via `Emitter`. States use `Equatable` so BlocBuilder only rebuilds on actual data changes.

### Infinite Scroll Bridge
`PagingController` from `infinite_scroll_pagination` is synced with the BLoC state inside `BlocListener`. This keeps state in BLoC while delegating pagination UI to the package.

### Debounced Search
A `Timer` in `SearchScreen` cancels and restarts on each keystroke, only firing the BLoC event after 300ms of inactivity — reducing unnecessary API calls.

### Hero Animation
`Hero(tag: 'movie-poster-\${movie.id}')` wraps the poster in both `MovieCard` and `MovieDetailScreen`. Flutter automatically interpolates the widget during the page transition.

### CustomPainter Stars
`StarRating` uses a `CustomPainter` to draw fractional stars on the canvas, demonstrating low-level drawing without image assets.

## Screenshots

> Add screenshots here after running the app.

## License

MIT
