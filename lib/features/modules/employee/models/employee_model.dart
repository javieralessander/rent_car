import 'dart:convert';

enum TandaLabor { matutina, vespertina, nocturna }

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
    switch (tanda.toLowerCase()) {
      case 'matutina':
        return TandaLabor.matutina;
      case 'vespertina':
        return TandaLabor.vespertina;
      case 'nocturna':
        return TandaLabor.nocturna;
      default:
        return TandaLabor.matutina;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'cedula': cedula,
      'tandaLabor': tandaLabor.name,
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
    return 'Empleado($id - $nombre - ${tandaLabor.name})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Employee && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
