import 'dart:convert';

enum CantidadCombustible { unCuarto, medio, tresCuartos, lleno }

class Inspection {
  final int id;
  final int vehiculo;
  final int cliente;
  final bool tieneRalladuras;
  final double cantidadCombustible;
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
      vehiculo: _extractId(json['vehiculo']),
      cliente: _extractId(json['cliente']),
      tieneRalladuras: json['tieneRalladuras'] ?? false,
      cantidadCombustible: _parseCantidadCombustible(json['cantidadCombustible']),
      tieneGomaRespuesta: json['tieneGomaRespuesta'] ?? false,
      tieneGato: json['tieneGato'] ?? false,
      tieneRoturasCristal: json['tieneRoturasCristal'] ?? false,
      estadoGoma1: json['estadoGomaDelanteraIzq'] ?? json['estadoGoma1'] ?? false,
      estadoGoma2: json['estadoGomaDelanteraDer'] ?? json['estadoGoma2'] ?? false,
      estadoGoma3: json['estadoGomaTraseraIzq'] ?? json['estadoGoma3'] ?? false,
      estadoGoma4: json['estadoGomaTraseraDer'] ?? json['estadoGoma4'] ?? false,
      fecha: DateTime.parse(json['fecha']),
      empleadoInspeccion: _extractId(json['empleado']),
      estado: json['estado'] ?? true,
    );
  }

  static int _extractId(dynamic obj) {
    if (obj == null) return 0;
    if (obj is int) return obj;
    if (obj is Map<String, dynamic> && obj.containsKey('id')) {
      return int.parse(obj['id'].toString());
    }
    return int.parse(obj.toString());
  }

  static double _parseCantidadCombustible(dynamic value) {
    if (value == null) return 0.25;

    String valueStr = value.toString().toLowerCase();

    // Mapear solo texto legible a decimal
    switch (valueStr) {
      case '1/4':
        return 0.25;
      case '1/2':
        return 0.50;
      case '3/4':
        return 0.75;
      case 'lleno':
        return 1.00;
      default:
        return 0.25; // Default a 1/4
    }
  }

  static double cantidadCombustibleFromEnum(CantidadCombustible cantidad) {
    switch (cantidad) {
      case CantidadCombustible.unCuarto:
        return 0.25;
      case CantidadCombustible.medio:
        return 0.50;
      case CantidadCombustible.tresCuartos:
        return 0.75;
      case CantidadCombustible.lleno:
        return 1.00;
    }
  }

  static CantidadCombustible cantidadCombustibleToEnum(double valor) {
    if (valor <= 0.30) return CantidadCombustible.unCuarto;
    if (valor <= 0.60) return CantidadCombustible.medio;
    if (valor <= 0.85) return CantidadCombustible.tresCuartos;
    return CantidadCombustible.lleno;
  }

  String get cantidadCombustibleString {
    if (cantidadCombustible <= 0.30) return '1/4';
    if (cantidadCombustible <= 0.60) return '1/2';
    if (cantidadCombustible <= 0.85) return '3/4';
    return 'Lleno';
  }

  String get cantidadCombustibleDisplay {
    if (cantidadCombustible <= 0.30) return '1/4';
    if (cantidadCombustible <= 0.60) return '½';
    if (cantidadCombustible <= 0.85) return '¾';
    return 'Lleno';
  }

  Map<String, dynamic> toJson() {
    return {
      'vehiculo': {'id': vehiculo},
      'cliente': {'id': cliente},
      'tieneRalladuras': tieneRalladuras,
      'cantidadCombustible': cantidadCombustible,
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
