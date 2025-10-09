import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rent_car/features/modules/brand/screens/brand_screen.dart';
import 'package:rent_car/features/modules/employee/screens/employee_screen.dart';

// Importa tus pantallas aquí
import '../../features/auth/guards/auth_guard.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/modules/vehicle_types/screens/vehicle_type_screen.dart';
import '../../features/modules/models/screens/model_screen.dart';
import '../../features/modules/fuel_types/screens/fuel_type_screen.dart';
import '../../features/modules/vehicles/screens/vehicle_screen.dart';
import '../../features/modules/clients/screens/client_screen.dart';
import '../../features/modules/inspection/screens/inspection_screen.dart';
import '../../features/modules/rental/screens/rental_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class NoTransitionPage<T> extends Page<T> {
  const NoTransitionPage({
    required this.child,
    LocalKey? key,
    String? name,
    Object? arguments,
  }) : super(key: key, name: name, arguments: arguments);

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  redirect: (context, state) {
    // Obtener el provider de autenticación
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final isLoading = authProvider.isLoading;

    // Rutas públicas que no requieren autenticación
    final publicRoutes = ['/login', '/register', '/forgot-password'];
    final isPublicRoute = publicRoutes.contains(state.matchedLocation);

    // Si está cargando, no redirigir
    if (isLoading) return null;

    // Si no está autenticado y no está en una ruta pública, ir a login
    if (!isLoggedIn && !isPublicRoute) {
      return '/login';
    }

    // Si está autenticado y está en una ruta pública, ir a home
    if (isLoggedIn && isPublicRoute) {
      return '/home';
    }

    // En cualquier otro caso, continuar normalmente
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RegisterScreen.name,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: ForgotPasswordScreen.name,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const AuthGuard(child: HomeScreen()),
      ),
    ),
    // Ruta para la pantalla de empleados
    GoRoute(
      path: '/empleados',
      name: EmployeeScreen.name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AuthGuard(child: EmployeeScreen()),
      ),
    ),
    GoRoute(
      path: '/clientes',
      name: ClientScreen.name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AuthGuard(child: ClientScreen()),
      ),
    ),
    GoRoute(
      path: '/marcas',
      name: BrandScreen.name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AuthGuard(child: BrandScreen()),
      ),
    ),
    GoRoute(
      path: '/tipos-vehiculos',
      name: VehicleTypeScreen.name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AuthGuard(child: VehicleTypeScreen()),
      ),
    ),
    GoRoute(
      path: '/modelos',
      name: ModelScreen.name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AuthGuard(child: ModelScreen()),
      ),
    ),
    GoRoute(
      path: '/tipos-combustible',
      name: FuelTypeScreen.name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AuthGuard(child: FuelTypeScreen()),
      ),
    ),
    GoRoute(
      path: '/vehiculos',
      name: VehicleScreen.name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AuthGuard(child: VehicleScreen()),
      ),
    ),
    GoRoute(
      path: '/inspecciones',
      name: InspectionScreen.name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AuthGuard(child: InspectionScreen()),
      ),
    ),
    GoRoute(
      path: '/rentas',
      name: RentalScreen.name,
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AuthGuard(child: RentalScreen()),
      ),
    ),
    // La rutas dependiendo de la estructura de la app
    // GoRoute(
    //   path: '/maps',
    //   name: CustomGoogleMaps.name,
    //   builder: (context, state) => const CustomGoogleMaps(),
    // ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Página no encontrada: ${state.error}')),
      ),
);
