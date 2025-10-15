import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionButton,
    this.illustration,
    this.backgroundColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? actionButton;
  final Widget? illustration;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Illustration or Icon
          if (illustration != null)
            illustration!
          else
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (backgroundColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                icon,
                size: 64,
                color: backgroundColor ?? AppColors.primary,
              ),
            ),

          const SizedBox(height: 24),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.grayDark,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Action Button
          if (actionButton != null) actionButton!,
        ],
      ),
    );
  }
}

class EmptyStateConfig {
  static EmptyStateWidget forInspections({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.assignment_turned_in_outlined,
      title: 'No hay inspecciones',
      description: 'Aún no has registrado ninguna inspección de vehículos.\nComienza agregando tu primera inspección.',
      backgroundColor: AppColors.info,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Nueva inspección'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }

  static EmptyStateWidget forVehicles({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.directions_car_outlined,
      title: 'No hay vehículos',
      description: 'Tu flota está vacía.\nAgrega vehículos para comenzar con las rentas.',
      backgroundColor: AppColors.primary,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Agregar vehículo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }

  static EmptyStateWidget forClients({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'No hay clientes',
      description: 'No tienes clientes registrados aún.\nComienza agregando tu primer cliente.',
      backgroundColor: AppColors.secondary,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Agregar cliente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }

  static EmptyStateWidget forRentals({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.car_rental_outlined,
      title: 'No hay rentas',
      description: 'No tienes rentas registradas.\nComienza creando tu primera renta.',
      backgroundColor: AppColors.success,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Nueva renta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }

  static EmptyStateWidget forEmployees({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.badge_outlined,
      title: 'No hay empleados',
      description: 'No tienes empleados registrados.\nAgrega empleados para gestionar las rentas.',
      backgroundColor: AppColors.warning,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Agregar empleado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }

  static EmptyStateWidget forBrands({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.branding_watermark_outlined,
      title: 'No hay marcas',
      description: 'No tienes marcas registradas.\nAgrega marcas para categorizar tus vehículos.',
      backgroundColor: AppColors.secondary,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Agregar marca'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }

  static EmptyStateWidget forModels({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.precision_manufacturing_outlined,
      title: 'No hay modelos',
      description: 'No tienes modelos registrados.\nAgrega modelos para especificar tus vehículos.',
      backgroundColor: AppColors.info,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Agregar modelo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }

  static EmptyStateWidget forVehicleTypes({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.category_outlined,
      title: 'No hay tipos de vehículos',
      description: 'No tienes tipos de vehículos registrados.\nAgrega tipos para clasificar tu flota.',
      backgroundColor: AppColors.primary,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tipo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }

  static EmptyStateWidget forFuelTypes({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      icon: Icons.local_gas_station_outlined,
      title: 'No hay tipos de combustible',
      description: 'No tienes tipos de combustible registrados.\nAgrega tipos para especificar el combustible de tus vehículos.',
      backgroundColor: AppColors.warning,
      actionButton: onAddPressed != null
          ? ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tipo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }
}