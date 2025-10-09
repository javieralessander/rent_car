import 'dart:convert';

class VehicleModel {
  final int id;
  final int idMarca;
  final String descripcion;
  final bool estado;

  VehicleModel({
    required this.id,
    required this.idMarca,
    required this.descripcion,
    this.estado = true,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: int.parse(json['id'].toString()),
      idMarca: int.parse(json['idMarca'].toString()),
      descripcion: json['descripcion'],
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'idMarca': idMarca, 'descripcion': descripcion, 'estado': estado};
  }

  factory VehicleModel.fromRawJson(String str) =>
      VehicleModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() => 'Modelo($id - $descripcion)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
