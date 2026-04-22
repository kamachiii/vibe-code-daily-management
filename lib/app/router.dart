import 'package:go_router/go_router.dart';
import 'package:smart_planner/features/auth/presentation/login_page.dart';
import 'package:smart_planner/features/schedules/presentation/schedules_page.dart';
import 'package:smart_planner/features/trip_ai/presentation/trip_ai_page.dart';

/// Route name constants — use these instead of raw strings.
abstract class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const tripAi = '/trip-ai';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const SchedulesPage(),
    ),
    GoRoute(
      path: AppRoutes.tripAi,
      name: 'trip-ai',
      builder: (context, state) => const TripAiPage(),
    ),
  ],
);
