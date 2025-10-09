import 'dart:convert';

import 'location.dart';

class Viewport {
  Viewport({required this.northeast, required this.southwest});

  Location northeast;
  Location southwest;

  factory Viewport.fromJson(String str) => Viewport.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Viewport.fromMap(Map<String, dynamic> json) => Viewport(
    northeast: Location.fromMap(json["northeast"]),
    southwest: Location.fromMap(json["southwest"]),
  );

  Map<String, dynamic> toMap() => {
    "northeast": northeast.toMap(),
    "southwest": southwest.toMap(),
  };
}
