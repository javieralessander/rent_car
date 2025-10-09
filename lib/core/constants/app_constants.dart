/// Constantes de la aplicación
class AppConstants {
  // Paginación
  static const int defaultItemsPerPage = 5;
  static const int maxItemsPerPage = 100;
  static const List<int> itemsPerPageOptions = [5, 10, 25, 50];

  // Tiempos
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 250);

  // Formatos
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Validaciones
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 255;
  static const int maxPhoneLength = 15;

  // Estados de solicitudes y órdenes
  static const String estadoPendiente = 'PENDIENTE';
  static const String estadoAprobada = 'APROBADA';
  static const String estadoRechazada = 'RECHAZADA';
  static const String estadoEnProceso = 'EN_PROCESO';
  static const String estadoCompletada = 'COMPLETADA';
  static const String estadoCancelada = 'CANCELADA';

  // Breakpoints responsivos
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Tamaños
  static const double maxDialogWidth = 600;
  static const double maxCardWidth = 400;

  // RegExp patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[\+]?[0-9]{10,15}$';
  static const String cedulaRncPattern = r'^[0-9]{11}$'; // Para RD
}
