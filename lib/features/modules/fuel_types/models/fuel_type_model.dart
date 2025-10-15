import 'dart:convert';

class FuelType {
  final int id;
  final String descripcion;
  final bool estado;

  FuelType({required this.id, required this.descripcion, this.estado = true});

  factory FuelType.fromJson(Map<String, dynamic> json) {
    return FuelType(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      descripcion: json['descripcion']?.toString() ?? '',
      estado: json['estado'] is bool
          ? json['estado']
          : (json['estado']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'descripcion': descripcion, 'estado': estado};
  }

  factory FuelType.fromRawJson(String str) =>
      FuelType.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() => 'TipoCombustible($id - $descripcion)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FuelType && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
