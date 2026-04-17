import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notesave/Router/route_names.dart';
import 'package:notesave/Views/Feature/Auth/LoginScreen/LoginScreen.dart';
import 'package:notesave/Views/Feature/Auth/Registration/RegistrationScreen.dart';
import 'package:notesave/Views/Feature/ErrorPage/errorpage.dart';
import 'package:notesave/Views/Feature/SplashScreen/splash_screen.dart';

// lib/Router/app_router.dart

class MyAppRouter {
  MyAppRouter._();
  static final MyAppRouter instance = MyAppRouter._();

  late final GoRouter router = GoRouter(
    initialLocation: AppPath.splash,
    routes: [
      GoRoute(
        path: AppPath.splash,
        name: AppRouteName.splash,
        pageBuilder: (context, state) =>
            MaterialPage(child: SplashScreen()),
      ),
      GoRoute(
        path: AppPath.login,
        name: AppRouteName.login,
        pageBuilder: (context, state) =>
            MaterialPage(child: LoginScreen()),
      ),
      GoRoute(
        path: AppPath.register,
        name: AppRouteName.register,
        pageBuilder: (context, state) =>
            MaterialPage(child: Registrationscreen()),
      ),
    ],
    errorPageBuilder: (context, state) =>
        MaterialPage(child: ErrorPage()),
  );
}