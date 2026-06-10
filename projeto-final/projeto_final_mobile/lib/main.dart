import 'package:flutter/material.dart';
import 'views/login/login_view.dart';

void main() {
  runApp(const MyApp());
}

const Color _primary    = Color(0xFF4166A0);
const Color _secondary  = Color(0xFF99C6E8);
const Color _background = Color(0xFFF2F9FE);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aqua Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _primary).copyWith(
          primary: _primary,
          secondary: _secondary,
          surface: _background,
        ),
        scaffoldBackgroundColor: _background,
        appBarTheme: const AppBarTheme(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _primary),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _primary, width: 2),
          ),
          labelStyle: TextStyle(color: _primary),
          floatingLabelStyle: TextStyle(color: _primary),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginView(),
    );
  }
}
