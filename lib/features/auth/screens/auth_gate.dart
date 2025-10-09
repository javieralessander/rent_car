import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/screens/login_screen.dart';

import 'package:provider/provider.dart';
import '../../home/screens/home_screen.dart';
import '../services/auth_service.dart';

class AuthGate extends StatelessWidget {
  static const String name = 'auth-gate';
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: context.read<AuthService>().isValidSession(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navegar una sola vez después de que el build actual termine
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final destino = snapshot.data! ? HomeScreen.name : LoginScreen.name;
          context.goNamed(destino);
        });

        // Mostrar pantalla vacía momentánea
        return const SizedBox.shrink();
      },
    );
  }
}
