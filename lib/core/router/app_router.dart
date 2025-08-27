import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:omni/core/session/user_session.dart';
import 'package:omni/features/home/presentation/pages/home_page.dart';
import 'package:omni/features/add/presentation/pages/add_page.dart';
import 'package:omni/features/analytics/presentation/pages/analytics_page.dart';
import 'package:omni/features/auth/presentation/pages/login_page.dart';
import 'package:omni/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:omni/features/goals/presentation/pages/goals_page.dart';
import 'package:omni/features/groups/presentation/pages/groups_page.dart';
import 'package:omni/features/settings/presentation/pages/user_settings_page.dart';

GoRouter createRouter() {
  final session = UserSession();
  return GoRouter(
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),
      GoRoute(path: '/', builder: (c, s) => const HomePage()),
      GoRoute(path: '/add', builder: (c, s) => const AddPage()),
      GoRoute(path: '/analytics', builder: (c, s) => const AnalyticsPage()),
      GoRoute(path: '/goals', builder: (c, s) => const GoalsPage()),
      GoRoute(path: '/groups', builder: (c, s) => const GroupsPage()),
      GoRoute(path: '/settings', builder: (c, s) => const UserSettingsPage()),
    ],
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn = state.matchedLocation == '/login';
      final onboarding = state.matchedLocation == '/onboarding';
      final needsOnboarding = session.needsOnboarding == true;
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && needsOnboarding && !onboarding) return '/onboarding';
      if (loggedIn && !needsOnboarding && (loggingIn || onboarding)) return '/';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
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
