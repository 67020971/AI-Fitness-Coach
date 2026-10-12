import 'package:flutter/material.dart';

import 'ui/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AIFitnessCoachApp());
}

class AIFitnessCoachApp extends StatelessWidget {
  const AIFitnessCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF14231F);
    const lime = Color(0xFFC6F36B);

    return MaterialApp(
      title: 'AI Fitness Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F5EF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: ink,
          primary: ink,
          secondary: lime,
          surface: const Color(0xFFF4F5EF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F5EF),
          foregroundColor: ink,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE2E6DC)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: ink,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}