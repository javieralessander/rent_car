import 'dart:convert';
import '../../brand/models/brand_model.dart';

class Model {
  final int? id;
  final Brand? marca;
  final String descripcion;
  final bool estado;

  Model({
    this.id,
    this.marca,
    required this.descripcion,
    this.estado = true,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      marca: json['marca'] != null ? Brand.fromJson(json['marca']) : null,
      descripcion: json['descripcion'],
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'marca': marca != null ? {'id': marca!.id} : null,
      'descripcion': descripcion,
      'estado': estado,
    };
  }

  factory Model.fromRawJson(String str) =>
      Model.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() => 'Modelo($id - $descripcion)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Model &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
