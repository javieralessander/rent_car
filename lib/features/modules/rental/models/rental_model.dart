import 'dart:convert';
import '../../../../shared/utils/input_validators.dart';

class Rental {
  final int id;
  final int empleado;
  final int vehiculo;
  final int cliente;
  final DateTime fechaRenta;
  final DateTime? fechaDevolucion;
  final double montoPorDia;
  final int cantidadDias;
  final String comentario;
  final bool estado;

  Rental({
    required this.id,
    required this.empleado,
    required this.vehiculo,
    required this.cliente,
    required this.fechaRenta,
    this.fechaDevolucion,
    required this.montoPorDia,
    required this.cantidadDias,
    this.comentario = '',
    this.estado = true,
  });

  double get montoTotal => montoPorDia * cantidadDias;

  bool get esDevuelto => fechaDevolucion != null;

  int get diasReales => fechaDevolucion != null
      ? fechaDevolucion!.difference(fechaRenta).inDays
      : DateTime.now().difference(fechaRenta).inDays;

  double get costoReal => montoPorDia * diasReales;

  bool get rentalVencido => !esDevuelto &&
      DateTime.now().difference(fechaRenta).inDays > cantidadDias;

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: int.parse(json['id'].toString()),
      empleado: int.parse(json['empleado'].toString()),
      vehiculo: int.parse(json['vehiculo'].toString()),
      cliente: int.parse(json['cliente'].toString()),
      fechaRenta: DateTime.parse(json['fechaRenta']),
      fechaDevolucion:
          json['fechaDevolucion'] != null
              ? DateTime.parse(json['fechaDevolucion'])
              : null,
      montoPorDia: double.parse(json['montoPorDia'].toString()),
      cantidadDias: int.parse(json['cantidadDias'].toString()),
      comentario: json['comentario'] ?? '',
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empleado': empleado,
      'vehiculo': vehiculo,
      'cliente': cliente,
      'fechaRenta': fechaRenta.toIso8601String(),
      'fechaDevolucion': fechaDevolucion?.toIso8601String(),
      'montoPorDia': montoPorDia,
      'cantidadDias': cantidadDias,
      'comentario': comentario,
      'estado': estado,
    };
  }

  factory Rental.fromRawJson(String str) => Rental.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() =>
      'Renta($id - Cliente: $cliente - Vehiculo: $vehiculo - Total: ${InputFormatters.formatCurrency(montoTotal)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rental && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
