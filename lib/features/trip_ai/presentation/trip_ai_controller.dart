import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_planner/app/di.dart';
import 'package:smart_planner/features/trip_ai/data/trip_ai_repository.dart';
import 'package:smart_planner/features/trip_ai/domain/trip_plan.dart';

// ── Repository provider ───────────────────────────────────────────────────

final tripAiRepositoryProvider = Provider<TripAiRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return TripAiRepository(supabase);
});

// ── State ─────────────────────────────────────────────────────────────────

class TripAiState {
  const TripAiState({
    this.plan,
    this.isLoading = false,
    this.error,
  });

  final TripPlan? plan;
  final bool isLoading;
  final String? error;

  TripAiState copyWith({
    TripPlan? plan,
    bool? isLoading,
    String? error,
  }) {
    return TripAiState(
      plan: plan ?? this.plan,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────

class TripAiController extends Notifier<TripAiState> {
  @override
  TripAiState build() => const TripAiState();

  Future<void> generate({
    required String destination,
    required DateTime startDate,
    required int days,
    Map<String, dynamic> preferences = const {},
    int budgetTotal = 0,
  }) async {
    if (destination.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a destination.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(tripAiRepositoryProvider);
      final plan = await repo.generateTripPlan(
        destination: destination.trim(),
        startDate: startDate,
        days: days,
        preferences: preferences,
        budgetTotal: budgetTotal,
      );
      state = TripAiState(plan: plan);
    } catch (e) {
      state = TripAiState(error: e.toString());
    }
  }

  void reset() => state = const TripAiState();
}

// ── Provider ──────────────────────────────────────────────────────────────

final tripAiControllerProvider =
    NotifierProvider<TripAiController, TripAiState>(TripAiController.new);
