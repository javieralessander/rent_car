import 'vehicle_model.dart';
import '../../brand/models/brand_model.dart';
import '../../models/models/model_model.dart';
import '../../vehicle_types/models/vehicle_type_model.dart';
import '../../fuel_types/models/fuel_type_model.dart';
import 'dart:convert';

class VehicleForm {
  final int? id;
  final String descripcion;
  final String noChasis;
  final String noMotor;
  final String noPlaca;
  final int tipoVehiculoId;
  final int marcaId;
  final int? modeloId;
  final int tipoCombustibleId;
  final bool estado;

  VehicleForm({
    this.id,
    required this.descripcion,
    required this.noChasis,
    required this.noMotor,
    required this.noPlaca,
    required this.tipoVehiculoId,
    required this.marcaId,
    this.modeloId,
    required this.tipoCombustibleId,
    this.estado = true,
  });

  // Convertir a Vehicle usando objetos de los proveedores
  Vehicle toVehicle({
    VehicleType? vehicleType,
    Brand? brand,
    Model? model,
    FuelType? fuelType,
  }) {
    return Vehicle(
      id: id,
      descripcion: descripcion,
      noChasis: noChasis,
      noMotor: noMotor,
      noPlaca: noPlaca,
      tipoVehiculo: vehicleType,
      marca: brand,
      modelo: model,
      tipoCombustible: fuelType,
      estado: estado,
    );
  }

  // Crear desde Vehicle
  factory VehicleForm.fromVehicle(Vehicle vehicle) {
    return VehicleForm(
      id: vehicle.id,
      descripcion: vehicle.descripcion,
      noChasis: vehicle.noChasis,
      noMotor: vehicle.noMotor,
      noPlaca: vehicle.noPlaca,
      tipoVehiculoId: vehicle.tipoVehiculo?.id ?? 0,
      marcaId: vehicle.marca?.id ?? 0,
      modeloId: vehicle.modelo?.id ?? 0,
      tipoCombustibleId: vehicle.tipoCombustible?.id ?? 0,
      estado: vehicle.estado,
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      if (id != null) 'id': id,
      'descripcion': descripcion,
      'noChasis': noChasis,
      'noMotor': noMotor,
      'noPlaca': noPlaca,
      'tipoVehiculo': {'id': tipoVehiculoId},
      'marca': {'id': marcaId},
      if (modeloId != null) 'modelo': {'id': modeloId},
      'tipoCombustible': {'id': tipoCombustibleId},
      'estado': estado,
    };
  }

  factory VehicleForm.fromRawJson(String str) => VehicleForm.fromJson(json.decode(str));
  String toRawJson() => json.encode(toApiJson());

  factory VehicleForm.fromJson(Map<String, dynamic> json) {
    return VehicleForm(
      id: json['id'],
      descripcion: json['descripcion'],
      noChasis: json['noChasis'],
      noMotor: json['noMotor'],
      noPlaca: json['noPlaca'],
      tipoVehiculoId: json['tipoVehiculoId'] ?? json['tipoVehiculo']?['id'] ?? 0,
      marcaId: json['marcaId'] ?? json['marca']?['id'] ?? 0,
      modeloId: json['modeloId'] ?? json['modelo']?['id'] ?? 0,
      tipoCombustibleId: json['tipoCombustibleId'] ?? json['tipoCombustible']?['id'] ?? 0,
      estado: json['estado'] ?? true,
    );
  }

  @override
  String toString() => 'VehicleForm($id - $descripcion - $noPlaca)';
}