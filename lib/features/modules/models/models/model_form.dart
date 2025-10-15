import 'dart:convert';
import 'model_model.dart';
import '../../brand/models/brand_model.dart';

/// Modelo simplificado para formularios que usa IDs simples
class ModelForm {
  final int? id;
  final int marcaId;
  final String descripcion;
  final bool estado;

  ModelForm({
    this.id,
    required this.marcaId,
    required this.descripcion,
    this.estado = true,
  });

  /// Convertir a Model completo usando Brand del provider
  Model toModel({Brand? brand}) {
    return Model(
      id: id,
      marca: brand,
      descripcion: descripcion,
      estado: estado,
    );
  }

  /// Crear desde Model completo
  factory ModelForm.fromModel(Model model) {
    return ModelForm(
      id: model.id,
      marcaId: model.marca?.id ?? 0,
      descripcion: model.descripcion,
      estado: model.estado,
    );
  }

  /// Para enviar a la API (con objeto marca anidado)
  Map<String, dynamic> toApiJson() {
    return {
      if (id != null) 'id': id,
      'marca': {'id': marcaId},
      'descripcion': descripcion,
      'estado': estado,
    };
  }

  factory ModelForm.fromRawJson(String str) => ModelForm.fromJson(json.decode(str));
  String toRawJson() => json.encode(toApiJson());

  factory ModelForm.fromJson(Map<String, dynamic> json) {
    return ModelForm(
      id: json['id'],
      marcaId: json['marcaId'] ?? json['marca']?['id'] ?? 0,
      descripcion: json['descripcion'],
      estado: json['estado'] ?? true,
    );
  }

  @override
  String toString() => 'ModelForm($id - $descripcion - Marca: $marcaId)';
}