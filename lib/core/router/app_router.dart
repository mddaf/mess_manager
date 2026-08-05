import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register_screen.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/mess/mess_setup_screen.dart';
import '../../ui/screens/profile/user_profile_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Splash shown while AuthBloc resolves its initial state
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu_rounded, size: 64, color: Colors.deepOrange),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final authState = authBloc.state;
      final loc = state.matchedLocation;

      // 1. Auth still initialising — always show splash
      if (authState is AuthInitial || authState is AuthLoading) {
        return loc == '/splash' ? null : '/splash';
      }

      // 2. Not authenticated
      if (authState is Unauthenticated || authState is AuthError) {
        final isAuthRoute = loc == '/login' || loc == '/register';
        return isAuthRoute ? null : '/login';
      }

      // 3. Authenticated
      if (authState is Authenticated) {
        // Don't stay on splash or auth pages
        final isPublicRoute =
            loc == '/splash' || loc == '/login' || loc == '/register';
        if (isPublicRoute) return '/setup';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const MessSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final messId = state.uri.queryParameters['messId'] ?? '';
          return HomeScreen(messId: messId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
    ],
  );
}
