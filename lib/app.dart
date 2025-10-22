import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/main_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluence Pay Admin Panel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
