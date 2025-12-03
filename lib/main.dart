import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/rooms_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wsbahuwdqisafgvxkwfc.supabase.co', // replace with test URL if needed
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndzYmFodXdkcWlzYWZndnhrd2ZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxNzAwNDQsImV4cCI6MjA3OTc0NjA0NH0.YeCy3Ll9DkTyxSqlwbgoifhMMtYpSuPNKJ17visqKwU', // replace with test anon key if needed
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservation App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RoomsListScreen(), // skip splash/login and go directly
    );
  }
}
