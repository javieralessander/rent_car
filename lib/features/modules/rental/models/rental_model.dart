import 'dart:convert';
import '../../../../shared/utils/input_validators.dart';
import '../../employee/models/employee_model.dart';
import '../../vehicles/models/vehicle_model.dart';
import '../../clients/models/client_model.dart';

enum EstadoRenta {
  RESERVADA,     // Renta reservada pero vehículo no entregado aún
  ACTIVA,        // Vehículo entregado y en uso por el cliente
  DEVUELTA,      // Vehículo devuelto y renta completada
  VENCIDA,       // Renta que pasó la fecha límite sin devolución
  CANCELADA,     // Renta cancelada antes de entregar el vehículo
  PERDIDA        // Vehículo reportado como perdido/robado
}

class Rental {
  final int? noRenta;
  final Employee? empleado;
  final Vehicle? vehiculo;
  final Client? cliente;
  final DateTime fechaRenta;
  final DateTime? fechaDevolucion;
  final double montoDia;
  final int cantidadDias;
  final String? comentario;
  final EstadoRenta estado;

  Rental({
    this.noRenta,
    this.empleado,
    this.vehiculo,
    this.cliente,
    required this.fechaRenta,
    this.fechaDevolucion,
    required this.montoDia,
    required this.cantidadDias,
    this.comentario,
    this.estado = EstadoRenta.ACTIVA,
  });

  double get montoTotal => montoDia * cantidadDias;

  /// Fecha límite calculada para devolver el vehículo
  DateTime get fechaLimiteDevolucion => fechaRenta.add(Duration(days: cantidadDias));

  /// Días reales transcurridos desde la renta
  int get diasReales => fechaDevolucion != null
      ? fechaDevolucion!.difference(fechaRenta).inDays + 1
      : DateTime.now().difference(fechaRenta).inDays + 1;

  /// Costo real basado en días utilizados
  double get costoReal => montoDia * diasReales;

  /// Días de retraso (negativo si se devolvió temprano)
  int get diasRetraso => fechaDevolucion != null
      ? fechaDevolucion!.difference(fechaLimiteDevolucion).inDays
      : DateTime.now().difference(fechaLimiteDevolucion).inDays;

  /// Monto de penalización por retraso (si aplica)
  double get montoPenalizacion => diasRetraso > 0 ? diasRetraso * montoDia * 0.5 : 0.0;

  /// Monto total incluyendo penalizaciones
  double get montoTotalConPenalizacion => costoReal + montoPenalizacion;

  /// Estado calculado automáticamente basado en las fechas y estado manual
  EstadoRenta get estadoCalculado {
    final ahora = DateTime.now();

    switch (estado) {
      case EstadoRenta.CANCELADA:
      case EstadoRenta.PERDIDA:
        return estado; // Estados finales que no cambian

      case EstadoRenta.DEVUELTA:
        return EstadoRenta.DEVUELTA; // Ya fue devuelto

      case EstadoRenta.RESERVADA:
        // Si ya pasó la fecha de renta, debería estar activa
        if (ahora.isAfter(fechaRenta)) {
          return EstadoRenta.ACTIVA;
        }
        return EstadoRenta.RESERVADA;

      case EstadoRenta.ACTIVA:
        // Si pasó la fecha límite, está vencida
        if (ahora.isAfter(fechaLimiteDevolucion)) {
          return EstadoRenta.VENCIDA;
        }
        return EstadoRenta.ACTIVA;

      case EstadoRenta.VENCIDA:
        return EstadoRenta.VENCIDA;
    }
  }

  /// Descripción legible del estado
  String get estadoDescripcion {
    switch (estadoCalculado) {
      case EstadoRenta.RESERVADA:
        return 'Reservada';
      case EstadoRenta.ACTIVA:
        return 'En renta';
      case EstadoRenta.DEVUELTA:
        return 'Devuelta';
      case EstadoRenta.VENCIDA:
        return 'Vencida';
      case EstadoRenta.CANCELADA:
        return 'Cancelada';
      case EstadoRenta.PERDIDA:
        return 'Perdida';
    }
  }

  /// Color asociado al estado para la UI
  String get estadoColor {
    switch (estadoCalculado) {
      case EstadoRenta.RESERVADA:
        return 'info';      // Azul
      case EstadoRenta.ACTIVA:
        return 'success';   // Verde
      case EstadoRenta.DEVUELTA:
        return 'primary';   // Azul oscuro
      case EstadoRenta.VENCIDA:
        return 'warning';   // Naranja
      case EstadoRenta.CANCELADA:
      case EstadoRenta.PERDIDA:
        return 'danger';    // Rojo
    }
  }

  /// Indica si el vehículo ya fue devuelto físicamente
  bool get esDevuelto => estado == EstadoRenta.DEVUELTA;

  /// Indica si la renta necesita ser recibida (vehículo devuelto pero estado no actualizado)
  bool get necesitaRecibir => false; // Solo aplicaría en casos específicos

  /// Indica si la renta está vencida
  bool get estaVencida => estadoCalculado == EstadoRenta.VENCIDA;

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      noRenta: json['noRenta'] != null ? int.parse(json['noRenta'].toString()) : null,
      empleado: json['empleado'] != null ? Employee.fromJson(json['empleado']) : null,
      vehiculo: json['vehiculo'] != null ? Vehicle.fromJson(json['vehiculo']) : null,
      cliente: json['cliente'] != null ? Client.fromJson(json['cliente']) : null,
      fechaRenta: DateTime.parse(json['fechaRenta']),
      fechaDevolucion:
          json['fechaDevolucion'] != null
              ? DateTime.parse(json['fechaDevolucion'])
              : null,
      montoDia: double.parse(json['montoDia'].toString()),
      cantidadDias: int.parse(json['cantidadDias'].toString()),
      comentario: json['comentario'],
      estado: EstadoRenta.values.firstWhere(
        (e) => e.toString().split('.').last == json['estado'],
        orElse: () => EstadoRenta.ACTIVA,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (noRenta != null) 'noRenta': noRenta,
      'empleado': empleado != null ? {'id': empleado!.id} : null,
      'vehiculo': vehiculo != null ? {'id': vehiculo!.id} : null,
      'cliente': cliente != null ? {'id': cliente!.id} : null,
      'fechaRenta': fechaRenta.toIso8601String().split('T')[0],
      'fechaDevolucion': fechaDevolucion?.toIso8601String().split('T')[0],
      'montoDia': montoDia,
      'cantidadDias': cantidadDias,
      'comentario': comentario,
      'estado': estado.toString().split('.').last,
    };
  }

  factory Rental.fromRawJson(String str) => Rental.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() =>
      'Renta($noRenta - Cliente: ${cliente?.nombre} - Vehiculo: ${vehiculo?.descripcion} - Total: ${InputFormatters.formatCurrency(montoTotal)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rental && runtimeType == other.runtimeType && noRenta == other.noRenta;

  @override
  int get hashCode => noRenta.hashCode;
}
