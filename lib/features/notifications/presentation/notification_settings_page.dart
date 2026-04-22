import 'package:flutter/material.dart';

/// Placeholder page for notification preferences.
/// TODO: allow user to enable/disable notification channels.
class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: const Center(child: Text('Notification settings — coming soon')),
    );
  }
}
