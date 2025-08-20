// lib/app_routes.dart
import 'package:app_laundry/screens/login_screen.dart';
import 'package:app_laundry/screens/register_screen.dart';
import 'package:app_laundry/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const RegisterScreen(),
  };
}
