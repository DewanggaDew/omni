import 'package:go_router/go_router.dart';
import 'package:omni/features/home/presentation/pages/home_page.dart';
import 'package:omni/features/add/presentation/pages/add_page.dart';
import 'package:omni/features/analytics/presentation/pages/analytics_page.dart';
import 'package:omni/features/goals/presentation/pages/goals_page.dart';
import 'package:omni/features/groups/presentation/pages/groups_page.dart';

GoRouter createRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomePage()),
      GoRoute(path: '/add', builder: (c, s) => const AddPage()),
      GoRoute(path: '/analytics', builder: (c, s) => const AnalyticsPage()),
      GoRoute(path: '/goals', builder: (c, s) => const GoalsPage()),
      GoRoute(path: '/groups', builder: (c, s) => const GroupsPage()),
    ],
  );
}
