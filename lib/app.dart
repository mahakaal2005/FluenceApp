import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/login_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/main_screen.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/users_bloc.dart';
import 'blocs/posts_bloc.dart';
import 'blocs/transactions_bloc.dart';
import 'blocs/dashboard_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<UsersBloc>(
          create: (context) => UsersBloc(),
        ),
        BlocProvider<PostsBloc>(
          create: (context) => PostsBloc(),
        ),
        BlocProvider<TransactionsBloc>(
          create: (context) => TransactionsBloc(),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Fluence Pay Admin Panel',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/main': (context) => const MainScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status immediately when app starts
    context.read<AuthBloc>().add(AuthStatusChecked());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/main');
        } else if (state is AuthUnauthenticated || state is AuthError) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: const LoginScreen(), // Show login screen while checking auth
    );
  }
}
