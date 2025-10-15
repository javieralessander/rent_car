import 'dart:convert';
import 'rental_model.dart';
import '../../employee/models/employee_model.dart';
import '../../vehicles/models/vehicle_model.dart';
import '../../clients/models/client_model.dart';

/// Modelo simplificado para formularios de rentas que usa IDs simples
class RentalForm {
  final int? noRenta;
  final int empleadoId;
  final int vehiculoId;
  final int clienteId;
  final DateTime fechaRenta;
  final DateTime? fechaDevolucion;
  final double montoDia;
  final int cantidadDias;
  final String? comentario;
  final EstadoRenta estado;

  RentalForm({
    this.noRenta,
    required this.empleadoId,
    required this.vehiculoId,
    required this.clienteId,
    required this.fechaRenta,
    this.fechaDevolucion,
    required this.montoDia,
    required this.cantidadDias,
    this.comentario,
    this.estado = EstadoRenta.ACTIVA,
  });

  double get montoTotal => montoDia * cantidadDias;
  bool get esDevuelto => fechaDevolucion != null;

  /// Convertir a Rental completo usando objetos de los providers
  Rental toRental({
    Employee? empleado,
    Vehicle? vehiculo,
    Client? cliente,
  }) {
    return Rental(
      noRenta: noRenta,
      empleado: empleado,
      vehiculo: vehiculo,
      cliente: cliente,
      fechaRenta: fechaRenta,
      fechaDevolucion: fechaDevolucion,
      montoDia: montoDia,
      cantidadDias: cantidadDias,
      comentario: comentario,
      estado: estado,
    );
  }

  /// Crear desde Rental completo
  factory RentalForm.fromRental(Rental rental) {
    return RentalForm(
      noRenta: rental.noRenta,
      empleadoId: rental.empleado?.id ?? 0,
      vehiculoId: rental.vehiculo?.id ?? 0,
      clienteId: rental.cliente?.id ?? 0,
      fechaRenta: rental.fechaRenta,
      fechaDevolucion: rental.fechaDevolucion,
      montoDia: rental.montoDia,
      cantidadDias: rental.cantidadDias,
      comentario: rental.comentario,
      estado: rental.estado,
    );
  }

  /// Para enviar a la API (con objetos anidados)
  Map<String, dynamic> toApiJson() {
    return {
      if (noRenta != null) 'noRenta': noRenta,
      'empleado': {'id': empleadoId},
      'vehiculo': {'id': vehiculoId},
      'cliente': {'id': clienteId},
      'fechaRenta': fechaRenta.toIso8601String().split('T')[0],
      'fechaDevolucion': fechaDevolucion?.toIso8601String().split('T')[0],
      'montoDia': montoDia,
      'cantidadDias': cantidadDias,
      'comentario': comentario,
      'estado': estado.toString().split('.').last,
    };
  }

  factory RentalForm.fromRawJson(String str) => RentalForm.fromJson(json.decode(str));
  String toRawJson() => json.encode(toApiJson());

  factory RentalForm.fromJson(Map<String, dynamic> json) {
    return RentalForm(
      noRenta: json['noRenta'],
      empleadoId: json['empleadoId'] ?? json['empleado']?['id'] ?? 0,
      vehiculoId: json['vehiculoId'] ?? json['vehiculo']?['id'] ?? 0,
      clienteId: json['clienteId'] ?? json['cliente']?['id'] ?? 0,
      fechaRenta: DateTime.parse(json['fechaRenta']),
      fechaDevolucion: json['fechaDevolucion'] != null
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

  @override
  String toString() => 'RentaForm($noRenta - Empleado: $empleadoId - Vehiculo: $vehiculoId - Cliente: $clienteId)';
}