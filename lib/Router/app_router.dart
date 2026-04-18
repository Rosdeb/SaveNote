import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notesave/Router/route_names.dart';
import 'package:notesave/Views/Feature/Auth/LoginScreen/LoginScreen.dart';
import 'package:notesave/Views/Feature/Auth/Registration/RegistrationScreen.dart';
import 'package:notesave/Views/Feature/Auth/VerifyScreen/verifyscreen.dart';
import 'package:notesave/Views/Feature/ErrorPage/errorpage.dart';
import 'package:notesave/Views/Feature/HomeScreen/CreateNoteScreen/createnoteScreen.dart';
import 'package:notesave/Views/Feature/HomeScreen/EditScreen/editScreen.dart';
import 'package:notesave/Views/Feature/HomeScreen/NoteDetailScreen/notedetailScreen.dart';
import 'package:notesave/Views/Feature/SplashScreen/splash_screen.dart';
import '../Models/Note/noteitem.dart';
import '../Views/Feature/HomeScreen/HomeScreen.dart';

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
        path: AppPath.home,
        name: AppRouteName.home,
        pageBuilder: (context, state) =>
            MaterialPage(child: HomeScreen()),
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
      GoRoute(
        path: AppPath.notedetails,
        name: AppRouteName.notedetails,
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return MaterialPage(
            child: NoteDetailsScreen(
              id: data['id'],
              title: data['title'],
              description: data['description'],
            ),
          );
        },
      ),

      GoRoute(
        path: AppPath.createnoteScreen,
        name: AppRouteName.createnoteScreen,
        pageBuilder: (context, state) =>
            MaterialPage(child: CreateNoteScreen()),
      ),

      GoRoute(
        path: AppPath.editScreen,
        name: AppRouteName.editScreen,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final note = args['note'] as NoteModel;
          final index = args['index'] as int;
          return MaterialPage(
            child: EditNoteScreen(note: note, index: index),
          );
        },
      ),

      GoRoute(
        path: AppPath.verifyscreen,
        name: AppRouteName.verifyscreen,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final email = args['email'] as String;
          return MaterialPage(
            child: VerifyScreen(email: email)
          );
        },
      ),


    ],
    errorPageBuilder: (context, state) =>
        MaterialPage(child: ErrorPage()),
  );
}