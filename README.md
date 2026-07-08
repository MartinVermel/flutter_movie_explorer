<div align="center">

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/flutter/flutter-original.svg" alt="Flutter" width="80" />

# Flutter Movie Explorer

**Browse movies with BLoC, Hero animations and infinite scroll**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State](https://img.shields.io/badge/State-BLoC-FF6B6B)](https://bloclibrary.dev)
[![API](https://img.shields.io/badge/API-TMDB-01D277?logo=themoviedatabase&logoColor=white)](https://www.themoviedb.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Infinite-scroll movie grid backed by the TMDB API, with shimmer skeleton loading, Hero shared-element transitions, debounced search, and declarative routing via go_router.

</div>

---

## Screenshots

<div align="center">

| Movie Grid | Shimmer Loading | Movie Detail | Search |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/movie_list.png" width="180" alt="Movie Grid" /> | <img src="docs/screenshots/shimmer.png" width="180" alt="Shimmer" /> | <img src="docs/screenshots/detail.png" width="180" alt="Movie Detail" /> | <img src="docs/screenshots/search.png" width="180" alt="Search" /> |

> **Note:** Screenshots coming soon. Run locally with your TMDB API key to see the full experience.

</div>

---

## Features

- 🎬 **Infinite scroll grid** — 2-column movie grid with automatic pagination via `infinite_scroll_pagination`
- ✨ **Shimmer loading** — `MovieCardSkeleton` matches the real card layout for a seamless data-load transition
- 🦸 **Hero animation** — shared-element poster transition between grid and detail screen
- 🔍 **Debounced search** — 300ms `Timer`-based debounce; recent search history persisted in BLoC state
- 📋 **Movie details** — backdrop blurred header, genre chips, cast, rating stars, similar movies row
- ⚠️ **Error / empty states** — retry support in both list and search screens
- 🗺 **go_router** — `/`, `/movie/:id`, `/search` with typed path params

---

## Architecture

BLoC pattern with feature-first folder structure:

```
lib/
├── core/
│   ├── constants/        # TMDB base URL, image base URL, placeholder key
│   ├── router/           # go_router setup — 3 routes with path params
│   ├── services/         # MovieService (Dio + API key interceptor)
│   └── theme/            # Dark-first MaterialTheme
└── features/
    └── movies/
        ├── bloc/
        │   ├── movie_bloc.dart         # MovieBloc — FetchMovies, FetchMoreMovies, SearchMovies
        │   ├── movie_event.dart        # Sealed-class-style events
        │   ├── movie_state.dart        # Immutable state with copyWith + Equatable
        │   └── movie_detail_bloc.dart  # Separate BLoC for detail screen
        ├── models/
        │   ├── movie.dart              # Movie (fromJson, poster URL helper)
        │   ├── movie_detail.dart       # MovieDetail with cast, genres, runtime
        │   └── movie_response.dart     # Paginated API response wrapper
        ├── screens/
        │   ├── movie_list_screen.dart  # BlocListener + BlocBuilder + PagedGridView
        │   ├── movie_detail_screen.dart# Hero + BackdropFilter + BlocBuilder
        │   └── search_screen.dart      # SearchBloc + debounce timer
        └── widgets/
            ├── movie_card.dart         # Hero-wrapped CachedNetworkImage card
            ├── movie_card_skeleton.dart# Shimmer placeholder matching card layout
            └── star_rating.dart        # Custom 5-star rating widget
```

**BLoC event flow:**
```
User scrolls to bottom
    → PagingController fires nextPageKey callback
        → MovieBloc.add(FetchMoreMovies(page: nextPage))
            → MovieBloc emits MovieLoaded(movies: [...old, ...new])
                → BlocListener calls PagingController.appendPage()
                    → PagedGridView renders new items
```

---

## Tech Stack

| Package | Version | Role |
|---|---|---|
| `flutter_bloc` | ^8.1.5 | BLoC state management |
| `equatable` | ^2.0.5 | Value equality for BLoC states |
| `go_router` | ^14.2.7 | Declarative navigation with typed path params |
| `infinite_scroll_pagination` | ^4.0.0 | Paginated list / grid UI |
| `shimmer` | ^3.0.0 | Skeleton loading animation |
| `dio` | ^5.4.3 | HTTP client with request interceptors |
| `cached_network_image` | ^3.3.1 | Disk + memory poster image caching |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- A free [TMDB API key](https://www.themoviedb.org/settings/api) (approved in ~1 minute)

### Installation

```bash
git clone https://github.com/MartinVermel/flutter_movie_explorer.git
cd flutter_movie_explorer
flutter pub get
```

### Configuration

Pass the key at build/run time, no file edit needed:

```bash
flutter run --dart-define=TMDB_API_KEY=your_key
```

It is read in `lib/core/constants/api_constants.dart` via `String.fromEnvironment`.

### Run

```bash
flutter run --dart-define=TMDB_API_KEY=your_key
```

---

## Docker

The app ships as a Flutter **web** build served by nginx, using a multi-stage `Dockerfile` (Flutter SDK build stage, then a ~100 MB nginx:alpine runtime image).

```bash
TMDB_API_KEY=your_key docker compose up --build
```
Open http://localhost:8102 (each project uses its own port so they can run side by side; override with `HOST_PORT=9000 docker compose up --build`).

Or without Compose:

```bash
docker build --build-arg TMDB_API_KEY=your_key -t flutter_movie_explorer .
docker run -p 8102:80 flutter_movie_explorer
```

`TMDB_API_KEY` is passed to `flutter build web --dart-define` at build time. Without it the app builds with a placeholder and the TMDB calls will fail. Note that any key compiled into a client-side bundle is visible to users, so use a restricted/free-tier key.

| File | Purpose |
|---|---|
| `Dockerfile` | Stage 1 builds `flutter build web --release`, stage 2 copies the output into nginx |
| `nginx.conf` | SPA fallback to `index.html`, gzip, long-lived cache for assets, no-cache for the bootstrap files |
| `docker-compose.yml` | One-command run on port 8102 |
| `.dockerignore` | Keeps `.git`, `build/` and `.dart_tool/` out of the build context |

Docker serves the web target only. For Android/iOS builds use `flutter run` as above.

---

## Key Implementation Notes

### `BlocListener` vs `BlocBuilder` — why both on the same screen
```dart
BlocListener<MovieBloc, MovieState>(
  listener: (context, state) {
    // Side effects only — does NOT trigger a rebuild
    if (state.isSuccess) {
      state.hasReachedMax
        ? _pagingController.appendLastPage(state.movies)
        : _pagingController.appendPage(state.movies, state.currentPage + 1);
    }
  },
  child: BlocBuilder<MovieBloc, MovieState>(
    builder: (context, state) => PagedGridView(...)  // rebuilds for UI state
  ),
)
```
`BlocListener` handles side effects (syncing `PagingController`) without causing rebuilds. `BlocBuilder` rebuilds the grid for UI-visible state changes. Using `BlocConsumer` would merge these, but separating them makes the intent explicit.

### Immutable BLoC state — spread append for pagination
```dart
// In MovieBloc._onFetchMoreMovies:
emit(state.copyWith(
  movies: [...state.movies, ...response.movies],  // new list, not mutation
  currentPage: nextPage,
  hasReachedMax: !response.hasNextPage,
));
```
The spread operator creates a new `List` without mutating existing state — required for `Equatable`'s identity-based change detection. Without this, `BlocBuilder` would not trigger a rebuild even though the list contents changed.

### Debounce — `Timer` cancel-and-restart pattern
```dart
Timer? _debounceTimer;

void _onSearchChanged(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
    context.read<MovieBloc>().add(SearchMovies(query: query));
  });
}

@override
void dispose() {
  _debounceTimer?.cancel();  // prevent callback after widget removal
  super.dispose();
}
```
Each keystroke resets the 300ms timer. The API call fires only when the user pauses. `dispose()` cancels any pending timer to prevent a state update on a removed widget.

---

## Project Structure Decisions

- **Why separate `MovieDetailBloc`?** The detail screen has an independent data lifecycle (single fetch, no pagination). Sharing `MovieBloc` would pollute its state shape and make it harder to test.
- **Why `PagingController` instead of a custom `ScrollController`?** `infinite_scroll_pagination` handles all pagination edge cases out of the box: first-page loading, appending pages, end-of-list, and per-page error/retry states. A manual `ScrollController` threshold check would need to replicate all of this.
- **Why `BackdropFilter` for the detail header?** It blurs the poster image that fills the header background, giving depth without loading a separate "blurred" image asset. The `ImageFilter.blur` applies at the compositor level — no Dart-side pixel manipulation.

---

## License

MIT © [Martin Vermel](https://github.com/MartinVermel)
