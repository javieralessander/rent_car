import 'dart:convert';

enum TipoPersona { fisica, juridica }

class Client {
  final int id;
  final String nombre;
  final String cedula;
  final String numeroTarjetaCR;
  final double limiteCredito;
  final TipoPersona tipoPersona;
  final bool estado;

  Client({
    required this.id,
    required this.nombre,
    required this.cedula,
    required this.numeroTarjetaCR,
    required this.limiteCredito,
    required this.tipoPersona,
    this.estado = true,
  });

  bool puedeRentar(double montoRenta) => estado && limiteCredito >= montoRenta;

  String get tipoPersonaTexto => tipoPersona == TipoPersona.fisica ? 'Física' : 'Jurídica';

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'],
      cedula: json['cedula'],
      numeroTarjetaCR: json['numeroTarjetaCR'],
      limiteCredito: double.parse(json['limiteCredito'].toString()),
      tipoPersona:
          json['tipoPersona'] == 'fisica'
              ? TipoPersona.fisica
              : TipoPersona.juridica,
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'cedula': cedula,
      'numeroTarjetaCR': numeroTarjetaCR,
      'limiteCredito': limiteCredito,
      'tipoPersona': tipoPersona == TipoPersona.fisica ? 'fisica' : 'juridica',
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
