import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

/// Widget que protege rutas requiriendo autenticación
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Mostrar loading mientras se verifica la sesión
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verificando sesión...'),
                ],
              ),
            ),
          );
        }

        // Si está autenticado, mostrar el contenido
        if (auth.isLoggedIn) {
          return SelectionArea(child: child);
        }

        // Si no está autenticado, mostrar login
        return const SelectionArea(child: LoginScreen());
      },
    );
  }
}

/// Widget para inicializar el estado de autenticación
class AuthInitializer extends StatefulWidget {
  final Widget child;

  const AuthInitializer({super.key, required this.child});

  @override
  State<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends State<AuthInitializer> {
  @override
  void initState() {
    super.initState();
    // Inicializar el estado de autenticación al inicio de la app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
