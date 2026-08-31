# Employee Management App

A production-style Flutter assignment demonstrating Clean Architecture, Repository Pattern, BLoC/Cubit, Firebase Authentication, Google Sign-In, REST CRUD, local caching, responsive UI, validation, themes and tests.

## Features
- Email/password Firebase login, registration and forgot-password
- Google Sign-In
- Auth-state based routing
- Employee GET/GET by ID/POST/PUT/DELETE against MockAPI
- Search by employee ID
- Filter by name/email/mobile/country
- Pull-to-refresh
- Add/edit/view employee form
- Country/state/district fields
- Hive cache fallback
- SharedPreferences theme persistence
- Light/dark theme
- Responsive cards/table-style employee list
- Loading/error/empty states
- Delete confirmation and success feedback
- Unit/widget tests using mocktail

## Firebase setup
1. Create a Firebase project.
2. Enable Authentication -> Email/Password and Google.
3. Add Android/iOS/Web apps as required.
4. Run `dart pub global activate flutterfire_cli` and `flutterfire configure` from this project, or manually replace `lib/firebase_options.dart` with generated options.
5. For Android, ensure the generated `android/app/google-services.json` exists. For iOS, add `GoogleService-Info.plist` through Xcode.

The checked-in `firebase_options.dart` intentionally contains placeholder values so the source tree is self-contained, but Firebase authentication requires real project configuration.

## Run
```bash
flutter pub get
flutter run
```

## Test
```bash
flutter test
```

## Notes
The API is MockAPI and is intentionally public. In a real production system, authentication tokens, environment-specific base URLs, secure storage and server-side validation should be added.
