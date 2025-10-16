import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rent_car/features/home/screens/home_screen.dart';
import '../../features/modules/vehicle_types/screens/vehicle_type_screen.dart';
import '../../features/modules/brand/screens/brand_screen.dart';
import '../../features/modules/clients/screens/client_screen.dart';
import '../../features/modules/employee/screens/employee_screen.dart';
import '../../features/modules/vehicles/screens/vehicle_screen.dart';
import '../../features/modules/rental/screens/rental_screen.dart';
import '../../features/modules/fuel_types/screens/fuel_type_screen.dart';
import '../../features/modules/models/screens/model_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

// 1. Define la clase de datos para los menús
class MenuItemData {
  final String title;
  final IconData icon;
  final String routeName;
  final String path;

  const MenuItemData({
    required this.title,
    required this.icon,
    required this.routeName,
    required this.path,
  });
}

// 2. Lista única de menús
const List<MenuItemData> appMenuItems = [
  MenuItemData(
    title: 'Portada',
    icon: Icons.dashboard,
    routeName: HomeScreen.name,
    path: '/home',
  ),
  MenuItemData(
    title: 'Clientes',
    icon: Icons.people,
    routeName: ClientScreen.name,
    path: '/clientes',
  ),
  MenuItemData(
    title: 'Vehículos',
    icon: Icons.directions_car,
    routeName: VehicleScreen.name,
    path: '/vehiculos',
  ),
  MenuItemData(
    title: 'Tipos Combustible',
    icon: Icons.local_gas_station,
    routeName: FuelTypeScreen.name,
    path: '/tipos-combustible',
  ),
  MenuItemData(
    title: 'Modelos',
    icon: Icons.model_training,
    routeName: ModelScreen.name,
    path: '/modelos',
  ),
  MenuItemData(
    title: 'Marcas',
    icon: Icons.branding_watermark,
    routeName: BrandScreen.name,
    path: '/marcas',
  ),
  MenuItemData(
    title: 'Tipos Vehículos',
    icon: Icons.category,
    routeName: VehicleTypeScreen.name,
    path: '/tipos-vehiculos',
  ),
  MenuItemData(
    title: 'Empleados',
    icon: Icons.badge,
    routeName: EmployeeScreen.name,
    path: '/empleados',
  ),
  MenuItemData(
    title: 'Inspecciones',
    icon: Icons.assignment,
    routeName: 'inspections',
    path: '/inspecciones',
  ),
  MenuItemData(
    title: 'Rentas',
    icon: Icons.car_rental,
    routeName: 'rentals',
    path: '/rentas',
  ),
];

class GenericAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final double height;

  const GenericAppBar({super.key, required this.isMobile, this.height = 140});

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    final isSmall = sizeScreen.width < 600;
    final isMedium = sizeScreen.width >= 600 && sizeScreen.width < 900;

    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: sizeScreen.width * 0.03,
        vertical: sizeScreen.height * 0.015,
      ),
      toolbarHeight:
          isSmall
              ? 90
              : isMedium
              ? 90
              : 90,
      title: GestureDetector(
        onTap: () {
          context.go('/home');
        },
        child: SvgPicture.asset(
          'assets/svgs/sicom.svg',
          height:
              isSmall
                  ? 32
                  : isMedium
                  ? 120
                  : 90,
        ),
      ),
      titleSpacing: isMobile ? 16 : sizeScreen.width * 0.03,
      centerTitle: isMobile,
      actions: [
        PopupMenuButton<String>(
          offset: const Offset(0, 40),
          child: Icon(
            Icons.account_circle_outlined,
            size: isSmall ? 28 : 32,
            color: Colors.black,
          ),
          onSelected: (String value) async {
            if (value == 'logout') {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text(
                        '¿Estás seguro de que quieres cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Cerrar Sesión'),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/auth');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sesión cerrada exitosamente'),
                    ),
                  );
                }
              }
            }
          },
          itemBuilder:
              (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
        if (!isSmall) ...[
          const SizedBox(width: 8),
          SizedBox(
            height: isMedium ? 40 : 52,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.currentUser;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nombre.toUpperCase() ?? 'USUARIO',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        user?.email.toUpperCase() ?? 'NO DISPONIBLE',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ],
      bottom:
          !isMobile
              ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sizeScreen.width * 0.03,
                    vertical: 4,
                  ),
                  height: 48,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 2),
                      bottom: BorderSide(color: Colors.grey.shade200, width: 2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for (final item in appMenuItems) ...[
                          HorizontalMenuItem(
                            title: item.title,
                            icon: item.icon,
                            routeName: item.routeName,
                            path: item.path,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              : PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: Colors.grey.shade300,
                  height: 1,
                  width: double.infinity,
                ),
              ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF0D2C4B)),
            child: Icon(Icons.shopping_cart, size: 48, color: Colors.white),
          ),
          for (final item in appMenuItems)
            _DrawerItem(
              title: item.title,
              icon: item.icon,
              routeName: item.routeName,
              path: item.path,
            ),
        ],
      ),
    );
  }
}

// ...existing code...
class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? routeName;
  final String path;

  const _DrawerItem({
    required this.title,
    required this.icon,
    this.routeName,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final String currentPath = GoRouterState.of(context).uri.toString();
    final bool isSelected = path == currentPath;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (routeName == null) return;
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.pop(context);
        }
        context.go(path);
      },
    );
  }
}

class HorizontalMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? routeName;
  final String path;

  const HorizontalMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.routeName,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    final String currentPath = router.routeInformationProvider.value.location;

    final bool isSelected = currentPath == path;

    return TextButton.icon(
      onPressed: () {
        if (routeName == null) return;
        context.go(path);
      },
      icon: Icon(icon, color: isSelected ? Colors.blue : Colors.black87),
      label: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.blue : Colors.black,
        backgroundColor:
            isSelected ? Colors.blue.withOpacity(0.08) : Colors.transparent,
      ),
    );
  }
}
