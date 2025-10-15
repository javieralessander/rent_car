import 'dart:convert';
import '../../vehicle_types/models/vehicle_type_model.dart';
import '../../brand/models/brand_model.dart';
import '../../models/models/model_model.dart';
import '../../fuel_types/models/fuel_type_model.dart';

class Vehicle {
  final int? id;
  final String descripcion;
  final String noChasis;
  final String noMotor;
  final String noPlaca;
  final VehicleType? tipoVehiculo;
  final Brand? marca;
  final Model? modelo;
  final FuelType? tipoCombustible;
  final bool estado;

  Vehicle({
    this.id,
    required this.descripcion,
    required this.noChasis,
    required this.noMotor,
    required this.noPlaca,
    this.tipoVehiculo,
    this.marca,
    this.modelo,
    this.tipoCombustible,
    this.estado = true,
  });

  bool get disponible => estado;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      descripcion: json['descripcion'],
      noChasis: json['noChasis'],
      noMotor: json['noMotor'],
      noPlaca: json['noPlaca'],
      tipoVehiculo: json['tipoVehiculo'] != null
          ? VehicleType.fromJson(json['tipoVehiculo'])
          : null,
      marca: json['marca'] != null ? Brand.fromJson(json['marca']) : null,
      modelo: json['modelo'] != null ? Model.fromJson(json['modelo']) : null,
      tipoCombustible: json['tipoCombustible'] != null
          ? FuelType.fromJson(json['tipoCombustible'])
          : null,
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'descripcion': descripcion,
      'noChasis': noChasis,
      'noMotor': noMotor,
      'noPlaca': noPlaca,
      'tipoVehiculo': tipoVehiculo != null ? {'id': tipoVehiculo!.id} : null,
      'marca': marca != null ? {'id': marca!.id} : null,
      'modelo': modelo != null ? {'id': modelo!.id} : null,
      'tipoCombustible': tipoCombustible != null ? {'id': tipoCombustible!.id} : null,
      'estado': estado,
    };
  }

  factory Vehicle.fromRawJson(String str) => Vehicle.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() => 'Vehiculo($id - $descripcion - $noPlaca)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
