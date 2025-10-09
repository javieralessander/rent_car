import 'dart:convert';

class Location {
  Location({required this.lat, required this.lng});

  double lat;
  double lng;

  factory Location.fromJson(String str) => Location.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Location.fromMap(Map<String, dynamic> json) =>
      Location(lat: json["lat"]?.toDouble(), lng: json["lng"]?.toDouble());

  Map<String, dynamic> toMap() => {"lat": lat, "lng": lng};
}
