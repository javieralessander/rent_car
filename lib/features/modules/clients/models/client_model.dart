import 'dart:convert';

enum TipoPersona { FISICA, JURIDICA }

class Client {
  final int? id;
  final String nombre;
  final String cedula;
  final String noTarjetaCr;
  final double limiteCredito;
  final TipoPersona tipoPersona;
  final bool estado;

  Client({
    this.id,
    required this.nombre,
    required this.cedula,
    required this.noTarjetaCr,
    required this.limiteCredito,
    required this.tipoPersona,
    this.estado = true,
  });

  bool puedeRentar(double montoRenta) => estado && limiteCredito >= montoRenta;

  String get tipoPersonaTexto => tipoPersona == TipoPersona.FISICA ? 'Física' : 'Jurídica';

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      nombre: json['nombre'],
      cedula: json['cedula'],
      noTarjetaCr: json['noTarjetaCr'],
      limiteCredito: double.parse(json['limiteCredito'].toString()),
      tipoPersona: TipoPersona.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipoPersona'],
        orElse: () => TipoPersona.FISICA,
      ),
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'cedula': cedula,
      'noTarjetaCr': noTarjetaCr,
      'limiteCredito': limiteCredito,
      'tipoPersona': tipoPersona.toString().split('.').last,
      'estado': estado,
    };
  }

  factory Client.fromRawJson(String str) => Client.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() => 'Cliente($id - $nombre - $cedula)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
