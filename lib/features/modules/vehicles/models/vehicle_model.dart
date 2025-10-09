import 'dart:convert';

class Vehicle {
  final int id;
  final String descripcion;
  final String numeroChasis;
  final String numeroMotor;
  final String numeroPlaca;
  final int tipoVehiculo;
  final int marca;
  final int modelo;
  final int tipoCombustible;
  final bool estado;

  Vehicle({
    required this.id,
    required this.descripcion,
    required this.numeroChasis,
    required this.numeroMotor,
    required this.numeroPlaca,
    required this.tipoVehiculo,
    required this.marca,
    required this.modelo,
    required this.tipoCombustible,
    this.estado = true,
  });

  bool get disponible => estado;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: int.parse(json['id'].toString()),
      descripcion: json['descripcion'],
      numeroChasis: json['numeroChasis'],
      numeroMotor: json['numeroMotor'],
      numeroPlaca: json['numeroPlaca'],
      tipoVehiculo: int.parse(json['tipoVehiculo'].toString()),
      marca: int.parse(json['marca'].toString()),
      modelo: int.parse(json['modelo'].toString()),
      tipoCombustible: int.parse(json['tipoCombustible'].toString()),
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descripcion': descripcion,
      'numeroChasis': numeroChasis,
      'numeroMotor': numeroMotor,
      'numeroPlaca': numeroPlaca,
      'tipoVehiculo': tipoVehiculo,
      'marca': marca,
      'modelo': modelo,
      'tipoCombustible': tipoCombustible,
      'estado': estado,
    };
  }

  factory Vehicle.fromRawJson(String str) => Vehicle.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() => 'Vehiculo($id - $descripcion - $numeroPlaca)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
