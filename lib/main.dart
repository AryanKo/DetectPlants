import 'package:flutter/material.dart';
import 'package:plant_disease_app/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DetectPlantsApp());
}

class DetectPlantsApp extends StatelessWidget {
  const DetectPlantsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detect Plants',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          brightness: Brightness.light,
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF81C784),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
          titleLarge: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
          bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
          bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
