import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_planner/core/utils/datetime.dart';
import 'package:smart_planner/features/trip_ai/domain/trip_plan.dart';
import 'package:smart_planner/features/trip_ai/presentation/trip_ai_controller.dart';

/// UI page for the AI Trip Assistant.
///
/// Inputs: destination, start date, number of days (1–7).
/// Action: "Generate" button calls the Supabase Edge Function `trip-plan`.
/// Output: multi-day itinerary rendered in a scrollable list.
class TripAiPage extends ConsumerStatefulWidget {
  const TripAiPage({super.key});

  @override
  ConsumerState<TripAiPage> createState() => _TripAiPageState();
}

class _TripAiPageState extends ConsumerState<TripAiPage> {
  final _destinationController = TextEditingController();
  DateTime _startDate = DateTime.now();
  int _days = 1;

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _generate() {
    ref.read(tripAiControllerProvider.notifier).generate(
          destination: _destinationController.text,
          startDate: _startDate,
          days: _days,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripAiControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip AI Assistant'),
        actions: [
          if (state.plan != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset',
              onPressed: () =>
                  ref.read(tripAiControllerProvider.notifier).reset(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Input form ──────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        hintText: 'e.g. Yogyakarta',
                        prefixIcon: Icon(Icons.place),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    // Start date picker
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(4),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(formatShortDate(_startDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Days slider
                    Row(
                      children: [
                        const Text('Days: '),
                        Expanded(
                          child: Slider(
                            value: _days.toDouble(),
                            min: 1,
                            max: 7,
                            divisions: 6,
                            label: '$_days day${_days > 1 ? 's' : ''}',
                            onChanged: (v) =>
                                setState(() => _days = v.round()),
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          child: Text(
                            '$_days',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: state.isLoading ? null : _generate,
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                          state.isLoading ? 'Generating…' : 'Generate Plan'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Error banner ─────────────────────────────────────────────
            if (state.error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),

            // ── Result ───────────────────────────────────────────────────
            if (state.plan != null) _TripPlanResult(plan: state.plan!),
          ],
        ),
      ),
    );
  }
}

// ── Result widget ─────────────────────────────────────────────────────────

class _TripPlanResult extends StatelessWidget {
  const _TripPlanResult({required this.plan});

  final TripPlan plan;

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat('#,##0', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.namaTempat,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(plan.deskripsi),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Est. total: Rp ${currencyFmt.format(plan.estimasiBiaya)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Per-day itinerary
        ...plan.days.map((day) => _DayCard(day: day)),

        // Assumptions / warnings
        if (plan.assumptions.isNotEmpty || plan.warnings.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan.assumptions.isNotEmpty) ...[
                    const Text('Assumptions:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...plan.assumptions.map((a) => Text('• $a')),
                    const SizedBox(height: 8),
                  ],
                  if (plan.warnings.isNotEmpty) ...[
                    const Text('Warnings:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...plan.warnings.map((w) => Text('⚠ $w')),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final TripDay day;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          day.date,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: true,
        children: day.itinerary
            .map(
              (item) => ListTile(
                leading: Text(
                  item.waktuMulai,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                title: Text(item.aktivitas),
                subtitle: Text('${item.waktuMulai} – ${item.waktuSelesai}'),
              ),
            )
            .toList(),
      ),
    );
  }
}
