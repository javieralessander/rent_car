import 'dart:convert';

class VehicleType {
  final int id;
  final String descripcion;
  final bool estado;

  VehicleType({
    required this.id,
    required this.descripcion,
    this.estado = true,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: int.parse(json['id'].toString()),
      descripcion: json['descripcion'],
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'descripcion': descripcion, 'estado': estado};
  }

  // Métodos para trabajar con JSON crudo
  factory VehicleType.fromRawJson(String str) =>
      VehicleType.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() => 'TipoVehiculo($id - $descripcion)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleType &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
