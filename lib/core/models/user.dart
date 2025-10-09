import 'dart:convert';

enum UserGender { male, female, other }

extension UserGenderExtension on UserGender {
  String get value {
    switch (this) {
      case UserGender.male:
        return 'M';
      case UserGender.female:
        return 'F';
      case UserGender.other:
        return 'NA';
    }
  }

  String get label {
    switch (this) {
      case UserGender.male:
        return 'Masculino';
      case UserGender.female:
        return 'Femenino';
      case UserGender.other:
        return 'Prefiero no especificar';
    }
  }

  static UserGender fromValue(String value) {
    switch (value) {
      case 'M':
        return UserGender.male;
      case 'F':
        return UserGender.female;
      case 'NA':
      default:
        return UserGender.other;
    }
  }
}

class User {
  String? id;
  String? name;
  String? email;
  String? password;
  UserGender? gender;
  String? rol; // Ejemplo: 'admin', 'comprador', 'empleado'
  bool? activo;

  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.gender,
    this.rol,
    this.activo = true,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    password: json["password"],
    gender:
        json["gender"] != null
            ? UserGenderExtension.fromValue(json["gender"])
            : null,
    rol: json["rol"],
    activo: json["activo"] ?? true,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "password": password,
    "gender": gender?.value,
    "rol": rol,
    "activo": activo,
  };
}
