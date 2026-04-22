import 'package:flutter/material.dart';

/// Placeholder page for managing user preferences (travel style, interests…).
/// TODO: Implement form with PreferencesRepository + Riverpod controller.
class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Preferences')),
      body: const Center(child: Text('Preferences — coming soon')),
    );
  }
}
