import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:omni/features/home/presentation/pages/home_page.dart';
import 'package:omni/features/add/presentation/pages/add_page.dart';
import 'package:omni/features/analytics/presentation/pages/analytics_page.dart';
import 'package:omni/features/auth/presentation/pages/login_page.dart';
import 'package:omni/features/goals/presentation/pages/goals_page.dart';
import 'package:omni/features/groups/presentation/pages/groups_page.dart';

GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/', builder: (c, s) => const HomePage()),
      GoRoute(path: '/add', builder: (c, s) => const AddPage()),
      GoRoute(path: '/analytics', builder: (c, s) => const AnalyticsPage()),
      GoRoute(path: '/goals', builder: (c, s) => const GoalsPage()),
      GoRoute(path: '/groups', builder: (c, s) => const GroupsPage()),
    ],
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn = state.matchedLocation == '/login';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
