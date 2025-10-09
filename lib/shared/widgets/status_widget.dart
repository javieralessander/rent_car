import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';

/// Widget reutilizable para mostrar estados de manera consistente en toda la aplicación
class StatusWidget extends StatelessWidget {
  final String status;
  final StatusType type;
  final bool showIcon;
  final bool showBorder;
  final double? width;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const StatusWidget({
    super.key,
    required this.status,
    required this.type,
    this.showIcon = true,
    this.showBorder = true,
    this.width,
    this.textStyle,
    this.padding,
  });

  /// Constructor para órdenes de compra
  factory StatusWidget.purchaseOrder(
    String estado, {
    bool showIcon = true,
    bool showBorder = true,
    double? width,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
  }) {
    StatusType type;
    switch (estado) {
      case 'generada':
        type = StatusType.info;
        break;
      case 'procesada':
        type = StatusType.warning;
        break;
      case 'completada':
        type = StatusType.success;
        break;
      case 'cancelada':
        type = StatusType.danger;
        break;
      default:
        type = StatusType.neutral;
    }

    return StatusWidget(
      status: _getPurchaseOrderLabel(estado),
      type: type,
      showIcon: showIcon,
      showBorder: showBorder,
      width: width,
      textStyle: textStyle,
      padding: padding,
    );
  }

  /// Constructor para solicitudes de artículos
  factory StatusWidget.request(
    String estado, {
    bool showIcon = true,
    bool showBorder = true,
    double? width,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
  }) {
    StatusType type;
    switch (estado) {
      case 'pendiente':
        type = StatusType.warning;
        break;
      case 'aprobada':
        type = StatusType.success;
        break;
      case 'rechazada':
        type = StatusType.danger;
        break;
      default:
        type = StatusType.neutral;
    }

    return StatusWidget(
      status: _getRequestLabel(estado),
      type: type,
      showIcon: showIcon,
      showBorder: showBorder,
      width: width,
      textStyle: textStyle,
      padding: padding,
    );
  }

  /// Constructor para estados generales (activo/inactivo)
  factory StatusWidget.general(
    bool isActive, {
    bool showIcon = true,
    bool showBorder = true,
    double? width,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
  }) {
    return StatusWidget(
      status: isActive ? 'Activo' : 'Inactivo',
      type: isActive ? StatusType.success : StatusType.neutral,
      showIcon: showIcon,
      showBorder: showBorder,
      width: width,
      textStyle: textStyle,
      padding: padding,
    );
  }

  static String _getPurchaseOrderLabel(String estado) {
    switch (estado) {
      case 'generada':
        return 'Generada';
      case 'procesada':
        return 'Procesada';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  static String _getRequestLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      default:
        return estado;
    }
  }

  Color get _statusColor {
    switch (type) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.danger:
        return AppColors.danger;
      case StatusType.info:
        return AppColors.info;
      case StatusType.neutral:
        return AppColors.gray;
    }
  }

  IconData get _statusIcon {
    switch (type) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.warning:
        return Icons.schedule;
      case StatusType.danger:
        return Icons.cancel;
      case StatusType.info:
        return Icons.info;
      case StatusType.neutral:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      color: _statusColor,
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );

    final finalTextStyle =
        textStyle != null
            ? defaultTextStyle.merge(textStyle)
            : defaultTextStyle;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(_statusIcon, size: 14, color: _statusColor),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            status,
            style: finalTextStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final container = Container(
      width: width,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: showBorder ? Border.all(color: _statusColor, width: 1) : null,
      ),
      child: content,
    );

    return container;
  }
}

/// Chip especializado para estados que puede ser usado en DataTables
class StatusChip extends StatelessWidget {
  final String status;
  final StatusType type;
  final double? width;

  const StatusChip({
    super.key,
    required this.status,
    required this.type,
    this.width,
  });

  /// Constructor para órdenes de compra
  factory StatusChip.purchaseOrder(String estado, {double? width}) {
    StatusType type;
    switch (estado) {
      case 'generada':
        type = StatusType.info;
        break;
      case 'procesada':
        type = StatusType.warning;
        break;
      case 'completada':
        type = StatusType.success;
        break;
      case 'cancelada':
        type = StatusType.danger;
        break;
      default:
        type = StatusType.neutral;
    }

    return StatusChip(
      status: StatusWidget._getPurchaseOrderLabel(estado),
      type: type,
      width: width,
    );
  }

  /// Constructor para solicitudes de artículos
  factory StatusChip.request(String estado, {double? width}) {
    StatusType type;
    switch (estado) {
      case 'pendiente':
        type = StatusType.warning;
        break;
      case 'aprobada':
        type = StatusType.success;
        break;
      case 'rechazada':
        type = StatusType.danger;
        break;
      default:
        type = StatusType.neutral;
    }

    return StatusChip(
      status: StatusWidget._getRequestLabel(estado),
      type: type,
      width: width,
    );
  }

  /// Constructor para estados generales (activo/inactivo)
  factory StatusChip.general(bool isActive, {double? width}) {
    return StatusChip(
      status: isActive ? 'Activo' : 'Inactivo',
      type: isActive ? StatusType.success : StatusType.neutral,
      width: width,
    );
  }

  Color get _statusColor {
    switch (type) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.danger:
        return AppColors.danger;
      case StatusType.info:
        return AppColors.info;
      case StatusType.neutral:
        return AppColors.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      side: BorderSide(color: _statusColor),
      backgroundColor: _statusColor.withValues(alpha: 0.15),
      label: SizedBox(
        width: width,
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _statusColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Tipos de estado disponibles
enum StatusType { success, warning, danger, info, neutral }
