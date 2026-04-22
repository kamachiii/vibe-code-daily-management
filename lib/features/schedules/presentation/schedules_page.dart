import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_planner/app/router.dart';

/// Main schedules / home page.
/// TODO: Connect to SchedulesRepository + Riverpod provider for real data.
class SchedulesPage extends StatelessWidget {
  const SchedulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Trip AI',
            onPressed: () => context.go(AppRoutes.tripAi),
          ),
        ],
      ),
      body: const Center(child: Text('Your schedules will appear here.')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to schedule form
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
