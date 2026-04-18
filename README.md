# NoteSave

`NoteSave` is a Flutter notes application with email-based authentication, OTP verification, token-based session handling, and CRUD flows for personal notes.

The project is structured as a multi-platform Flutter app with Android, iOS, web, macOS, Windows, and Linux targets in the repository.

## Features

- Email/password registration
- OTP verification after signup
- Email/password login
- Persistent auth session using stored access and refresh tokens
- Automatic token refresh for protected API requests
- Network connectivity monitoring
- View current user profile information
- Upload profile avatar from the device gallery
- Create, list, view, edit, and delete notes

## Tech Stack

- Flutter
- Dart
- `go_router` for routing
- `get` for controllers and reactive state
- `http` for API calls
- `shared_preferences` for token and user data storage
- `connectivity_plus` for online/offline monitoring
- `image_picker` for avatar image selection
- `flutter_svg` and custom assets for UI

## Implemented App Flow

1. App starts at the splash route.
2. Users can register with name, email, and password.
3. After registration, the app navigates to OTP verification.
4. Verified users can log in with email and password.
5. On successful login, access and refresh tokens are stored locally.
6. Authenticated users land on the home screen and can manage notes.
7. Protected API calls retry automatically after token refresh when possible.

## Project Structure

```text
lib/
  Controller/
    AuthController/
    HomeController/
    NetworkService/
    SplashController/
  Models/
    Note/
    UserProfileResponse/
  Router/
  Services/
    Auth/
  Utils/
  Views/
    Base/
    Feature/
      Auth/
      HomeScreen/
      SplashScreen/
```

## Main Screens

- Splash screen
- Login screen
- Registration screen
- OTP verification screen
- Home screen with notes list
- Create note screen
- Edit note screen
- Note detail screen

## API Integration

The app is connected to a backend API for authentication, user profile, avatar upload, and note management.

Most non-auth API calls are centralized in [lib/Services/Auth/Api_Services.dart](/Users/rosdeb/BuisnessBuild/NoteSave/lib/Services/Auth/Api_Services.dart:1), which provides shared request handling for `GET`, `POST`, `PUT`, `PATCH`, multipart patch, and `DELETE` operations.

Authentication flows are the main exception right now. Login, registration, OTP verification, and token refresh are handled separately inside the auth layer instead of going through the shared `ApiService`.

Current API base URL:

```dart
https://rosdeb.xdtunnel.icu/api/v1
```

That base URL is currently hardcoded in [lib/Utils/AppConstant/app_constant.dart](/Users/rosdeb/BuisnessBuild/NoteSave/lib/Utils/AppConstant/app_constant.dart:1).

Examples of active endpoints referenced in the codebase:

- `/auth/register`
- `/auth/verify-account`
- `/auth/login`
- `/api/auth/renew-access-token`
- `/user/self/in`
- `/notes/all`
- `/notes/create`
- `/notes/update/:id`
- `/notes/delete/:id`

## Local Setup

### Prerequisites

- Flutter SDK installed
- Dart SDK matching the Flutter version in use
- A running backend compatible with the endpoints above

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

## Configuration Notes

- The repository includes a `.env` file and declares it in `pubspec.yaml`.
- `AppConstants` exposes `APP_NAME`, `STRIPE_PUBLIC_KEY`, and `STRIPE_SECRET_KEY`.
- The runtime API base URL is not currently read from `.env`; it is hardcoded in `app_constant.dart`.

## State Management And Routing

- Routing is defined with `GoRouter` in [lib/Router/app_router.dart](/Users/rosdeb/BuisnessBuild/NoteSave/lib/Router/app_router.dart:1).
- Reactive controllers use `GetX`.
- Token storage is handled by [lib/Utils/TokenServices/token_services.dart](/Users/rosdeb/BuisnessBuild/NoteSave/lib/Utils/TokenServices/token_services.dart:1).
- Network state is monitored by [lib/Controller/NetworkService/networkservice.dart](/Users/rosdeb/BuisnessBuild/NoteSave/lib/Controller/NetworkService/networkservice.dart:1).

## Current Limitations

- Social login buttons are present in the UI, but their actions are not implemented.
- The "Forgot Password?" entry is visible in the login screen, but the recovery flow is not implemented.
- The Google sign-in service file is commented out and not active.
- The existing widget test is still the default Flutter counter sample and does not match this app.

## Assets

The app includes:

- Custom `Inter` font files
- SVG icons
- Image assets for splash and branding

## Development

Useful commands:

```bash
flutter analyze
flutter run
```

If you want, the next README pass can be narrowed for one audience only, for example recruiters, open-source contributors, or internal team handoff.
