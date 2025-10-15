import 'dart:convert';
import '../../../../shared/utils/input_validators.dart';
import '../../employee/models/employee_model.dart';
import '../../vehicles/models/vehicle_model.dart';
import '../../clients/models/client_model.dart';

enum EstadoRenta { ACTIVA, DEVUELTA, CANCELADA }

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

  bool get esDevuelto => fechaDevolucion != null;

  int get diasReales => fechaDevolucion != null
      ? fechaDevolucion!.difference(fechaRenta).inDays
      : DateTime.now().difference(fechaRenta).inDays;

  double get costoReal => montoDia * diasReales;

  bool get rentalVencido => !esDevuelto &&
      DateTime.now().difference(fechaRenta).inDays > cantidadDias;

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
      'empleado': empleado?.toJson(),
      'vehiculo': vehiculo?.toJson(),
      'cliente': cliente?.toJson(),
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
