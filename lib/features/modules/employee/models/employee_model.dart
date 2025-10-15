import 'dart:convert';

enum TandaLabor { MATUTINA, VESPERTINA, NOCTURNA }

class Employee {
  final int id;
  final String nombre;
  final String cedula;
  final TandaLabor tandaLabor;
  final double porcientoComision;
  final DateTime fechaIngreso;
  final bool estado;

  Employee({
    required this.id,
    required this.nombre,
    required this.cedula,
    required this.tandaLabor,
    required this.porcientoComision,
    required this.fechaIngreso,
    this.estado = true,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'],
      cedula: json['cedula'],
      tandaLabor: _parseTandaLabor(json['tandaLabor']),
      porcientoComision: double.parse(json['porcientoComision'].toString()),
      fechaIngreso: DateTime.parse(json['fechaIngreso']),
      estado: json['estado'] ?? true,
    );
  }

  static TandaLabor _parseTandaLabor(String tanda) {
    switch (tanda.toUpperCase()) {
      case 'MATUTINA':
        return TandaLabor.MATUTINA;
      case 'VESPERTINA':
        return TandaLabor.VESPERTINA;
      case 'NOCTURNA':
        return TandaLabor.NOCTURNA;
      default:
        return TandaLabor.MATUTINA;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'cedula': cedula,
      'tandaLabor': tandaLabor.toString().split('.').last,
      'porcientoComision': porcientoComision,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'estado': estado,
    };
  }

  factory Employee.fromRawJson(String str) =>
      Employee.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() {
    return 'Empleado($id - $nombre - ${tandaLabor.toString().split('.').last})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
