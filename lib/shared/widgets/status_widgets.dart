import 'package:flutter/material.dart';

/// Widget para mostrar el estado activo/inactivo de manera visual
class StatusChip extends StatelessWidget {
  final bool isActive;
  final String? activeText;
  final String? inactiveText;
  final Color? activeColor;
  final Color? inactiveColor;

  const StatusChip({
    super.key,
    required this.isActive,
    this.activeText,
    this.inactiveText,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final text =
        isActive ? (activeText ?? 'Activo') : (inactiveText ?? 'Inactivo');

    final color =
        isActive
            ? (activeColor ?? Colors.green)
            : (inactiveColor ?? Colors.red);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Widget para mostrar estados específicos de solicitudes y órdenes
class RequestStatusChip extends StatelessWidget {
  final String status;

  const RequestStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pendiente':
        color = Colors.orange;
        displayText = 'Pendiente';
        break;
      case 'aprobada':
        color = Colors.green;
        displayText = 'Aprobada';
        break;
      case 'rechazada':
        color = Colors.red;
        displayText = 'Rechazada';
        break;
      case 'en_proceso':
        color = Colors.blue;
        displayText = 'En Proceso';
        break;
      case 'completada':
        color = Colors.teal;
        displayText = 'Completada';
        break;
      case 'cancelada':
        color = Colors.grey;
        displayText = 'Cancelada';
        break;
      default:
        color = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Extensión para convertir boolean a texto legible
extension BooleanDisplay on bool {
  String get activeText => this ? 'Activo' : 'Inactivo';
  String get enabledText => this ? 'Habilitado' : 'Deshabilitado';
  String get availableText => this ? 'Disponible' : 'No disponible';
}
