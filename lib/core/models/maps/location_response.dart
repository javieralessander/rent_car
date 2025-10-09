// To parse this JSON data, do
//
//     final locationResponse = locationResponseFromMap(jsonString);

import 'dart:convert';

class LocationResponse {
  LocationResponse({required this.results, required this.status});

  List<Result> results;
  String status;

  factory LocationResponse.fromJson(String str) =>
      LocationResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LocationResponse.fromMap(Map<String, dynamic> json) =>
      LocationResponse(
        results: List<Result>.from(
          json["results"].map((x) => Result.fromMap(x)),
        ),
        status: json["status"],
      );

  Map<String, dynamic> toMap() => {
    "results": List<dynamic>.from(results.map((x) => x.toMap())),
    "status": status,
  };
}

class Result {
  Result({
    required this.addressComponents,
    required this.formattedAddress,
    required this.geometry,
    required this.partialMatch,
    required this.placeId,
    required this.types,
  });

  List<AddressComponent> addressComponents;
  String formattedAddress;
  Geometry geometry;
  bool partialMatch;
  String placeId;
  List<String> types;

  factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Result.fromMap(Map<String, dynamic> json) => Result(
    addressComponents: List<AddressComponent>.from(
      json["address_components"].map((x) => AddressComponent.fromMap(x)),
    ),
    formattedAddress: json["formatted_address"],
    geometry: Geometry.fromMap(json["geometry"]),
    partialMatch: bool.fromEnvironment(json["partial_match"].toString()),
    placeId: json["place_id"],
    types: List<String>.from(json["types"].map((x) => x)),
  );

  Map<String, dynamic> toMap() => {
    "address_components": List<dynamic>.from(
      addressComponents.map((x) => x.toMap()),
    ),
    "formatted_address": formattedAddress,
    "geometry": geometry.toMap(),
    "partial_match": partialMatch,
    "place_id": placeId,
    "types": List<dynamic>.from(types.map((x) => x)),
  };
}

class AddressComponent {
  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  String longName;
  String shortName;
  List<String> types;

  factory AddressComponent.fromJson(String str) =>
      AddressComponent.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AddressComponent.fromMap(Map<String, dynamic> json) =>
      AddressComponent(
        longName: json["long_name"],
        shortName: json["short_name"],
        types: List<String>.from(json["types"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
    "long_name": longName,
    "short_name": shortName,
    "types": List<dynamic>.from(types.map((x) => x)),
  };
}

class Geometry {
  Geometry({
    required this.bounds,
    required this.location,
    required this.locationType,
    required this.viewport,
  });

  Bounds bounds;
  Location location;
  String locationType;
  Bounds viewport;

  factory Geometry.fromJson(String str) => Geometry.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Geometry.fromMap(Map<String, dynamic> json) {
    return Geometry(
      bounds:
          json["bounds"] != null
              ? Bounds.fromMap(json["bounds"])
              : Bounds.fromMap(json["viewport"]),
      location: Location.fromMap(json["location"]),
      locationType: json["location_type"],
      viewport: Bounds.fromMap(json["viewport"]),
    );
  }

  Map<String, dynamic> toMap() => {
    "bounds": bounds.toMap(),
    "location": location.toMap(),
    "location_type": locationType,
    "viewport": viewport.toMap(),
  };
}

class Bounds {
  Bounds({required this.northeast, required this.southwest});

  Location northeast;
  Location southwest;

  factory Bounds.fromJson(String str) => Bounds.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Bounds.fromMap(Map<String, dynamic> json) => Bounds(
    northeast: Location.fromMap(json["northeast"]),
    southwest: Location.fromMap(json["southwest"]),
  );

  Map<String, dynamic> toMap() => {
    "northeast": northeast.toMap(),
    "southwest": southwest.toMap(),
  };
}

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
