import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_planner/app/app.dart';
import 'package:smart_planner/core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // TODO: initialize Firebase (FirebaseApp.initializeApp) when google-services.json
  //       / GoogleService-Info.plist are added.

  runApp(
    const ProviderScope(
      child: SmartPlannerApp(),
    ),
  );
}
