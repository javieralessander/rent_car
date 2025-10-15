import 'dart:convert';

enum CantidadCombustible { unCuarto, medio, tresCuartos, lleno }

class Inspection {
  final int id;
  final int vehiculo;
  final int cliente;
  final bool tieneRalladuras;
  final CantidadCombustible cantidadCombustible;
  final bool tieneGomaRespuesta;
  final bool tieneGato;
  final bool tieneRoturasCristal;
  final bool estadoGoma1;
  final bool estadoGoma2;
  final bool estadoGoma3;
  final bool estadoGoma4;
  final DateTime fecha;
  final int empleadoInspeccion;
  final bool estado;

  Inspection({
    required this.id,
    required this.vehiculo,
    required this.cliente,
    required this.tieneRalladuras,
    required this.cantidadCombustible,
    required this.tieneGomaRespuesta,
    required this.tieneGato,
    required this.tieneRoturasCristal,
    required this.estadoGoma1,
    required this.estadoGoma2,
    required this.estadoGoma3,
    required this.estadoGoma4,
    required this.fecha,
    required this.empleadoInspeccion,
    this.estado = true,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: int.parse(json['id'].toString()),
      vehiculo: int.parse(json['vehiculo'].toString()),
      cliente: int.parse(json['cliente'].toString()),
      tieneRalladuras: json['tieneRalladuras'] ?? false,
      cantidadCombustible: _parseCantidadCombustible(
        json['cantidadCombustible'],
      ),
      tieneGomaRespuesta: json['tieneGomaRespuesta'] ?? false,
      tieneGato: json['tieneGato'] ?? false,
      tieneRoturasCristal: json['tieneRoturasCristal'] ?? false,
      estadoGoma1: json['estadoGoma1'] ?? false,
      estadoGoma2: json['estadoGoma2'] ?? false,
      estadoGoma3: json['estadoGoma3'] ?? false,
      estadoGoma4: json['estadoGoma4'] ?? false,
      fecha: DateTime.parse(json['fecha']),
      empleadoInspeccion: int.parse(json['empleadoInspeccion'].toString()),
      estado: json['estado'] ?? true,
    );
  }

  static CantidadCombustible _parseCantidadCombustible(String cantidad) {
    switch (cantidad.toLowerCase()) {
      case '1/4':
      case 'un_cuarto':
        return CantidadCombustible.unCuarto;
      case '1/2':
      case 'medio':
        return CantidadCombustible.medio;
      case '3/4':
      case 'tres_cuartos':
        return CantidadCombustible.tresCuartos;
      case 'lleno':
        return CantidadCombustible.lleno;
      default:
        return CantidadCombustible.unCuarto;
    }
  }

  String get cantidadCombustibleString {
    switch (cantidadCombustible) {
      case CantidadCombustible.unCuarto:
        return '1/4';
      case CantidadCombustible.medio:
        return '1/2';
      case CantidadCombustible.tresCuartos:
        return '3/4';
      case CantidadCombustible.lleno:
        return 'Lleno';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'vehiculo': {'id': vehiculo},
      'cliente': {'id': cliente},
      'tieneRalladuras': tieneRalladuras,
      'cantidadCombustible': cantidadCombustibleString.toUpperCase().replaceAll('/', '_').replaceAll(' ', '_'),
      'tieneGomaRespuesta': tieneGomaRespuesta,
      'tieneGato': tieneGato,
      'tieneRoturasCristal': tieneRoturasCristal,
      'estadoGomaDelanteraIzq': estadoGoma1,
      'estadoGomaDelanteraDer': estadoGoma2,
      'estadoGomaTraseraIzq': estadoGoma3,
      'estadoGomaTraseraDer': estadoGoma4,
      'fecha': fecha.toIso8601String(),
      'empleado': {'id': empleadoInspeccion},
      'estado': estado,
    };
  }

  factory Inspection.fromRawJson(String str) =>
      Inspection.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() =>
      'Inspeccion($id - Vehiculo: $vehiculo - Cliente: $cliente)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Inspection && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
