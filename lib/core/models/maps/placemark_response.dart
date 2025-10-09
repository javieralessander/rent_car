// To parse this JSON data, do
//
//     final placemarkResponse = placemarkResponseFromMap(jsonString);

import 'dart:convert';

import 'location.dart';
import 'plus_code.dart';
import 'viewport.dart';

class PlacemarkResponse {
  PlacemarkResponse({
    required this.plusCode,
    required this.results,
    required this.status,
  });

  PlusCode plusCode;
  List<Place> results;
  String status;

  factory PlacemarkResponse.fromJson(String str) =>
      PlacemarkResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PlacemarkResponse.fromMap(Map<String, dynamic> json) =>
      PlacemarkResponse(
        plusCode: PlusCode.fromMap(json["plus_code"]),
        results: List<Place>.from(json["results"].map((x) => Place.fromMap(x))),
        status: json["status"],
      );

  Map<String, dynamic> toMap() => {
    "plus_code": plusCode.toMap(),
    "results": List<dynamic>.from(results.map((x) => x.toMap())),
    "status": status,
  };
}

class Place {
  Place({
    required this.addressComponents,
    required this.formattedAddress,
    required this.geometry,
    required this.placeId,
    this.plusCode,
    required this.types,
  });

  List<AddressComponentPlacemark> addressComponents;
  String formattedAddress;
  GeometryPlacemark geometry;
  String placeId;
  PlusCode? plusCode;
  List<String> types;

  factory Place.fromJson(String str) => Place.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Place.fromMap(Map<String, dynamic> json) => Place(
    addressComponents: List<AddressComponentPlacemark>.from(
      json["address_components"].map(
        (x) => AddressComponentPlacemark.fromMap(x),
      ),
    ),
    formattedAddress: json["formatted_address"],
    geometry: GeometryPlacemark.fromMap(json["geometry"]),
    placeId: json["place_id"],
    plusCode:
        json["plus_code"] == null ? null : PlusCode.fromMap(json["plus_code"]),
    types: List<String>.from(json["types"].map((x) => x)),
  );

  Map<String, dynamic> toMap() => {
    "address_components": List<dynamic>.from(
      addressComponents.map((x) => x.toMap()),
    ),
    "formatted_address": formattedAddress,
    "geometry": geometry.toMap(),
    "place_id": placeId,
    "plus_code": plusCode?.toMap(),
    "types": List<dynamic>.from(types.map((x) => x)),
  };
}

class AddressComponentPlacemark {
  AddressComponentPlacemark({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  String longName;
  String shortName;
  List<String> types;

  factory AddressComponentPlacemark.fromJson(String str) =>
      AddressComponentPlacemark.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AddressComponentPlacemark.fromMap(Map<String, dynamic> json) =>
      AddressComponentPlacemark(
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

class GeometryPlacemark {
  GeometryPlacemark({
    required this.location,
    required this.locationType,
    required this.viewport,
    this.bounds,
  });

  Location location;
  String locationType;
  Viewport viewport;
  Viewport? bounds;

  factory GeometryPlacemark.fromJson(String str) =>
      GeometryPlacemark.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GeometryPlacemark.fromMap(Map<String, dynamic> json) =>
      GeometryPlacemark(
        location: Location.fromMap(json["location"]),
        locationType: json["location_type"],
        viewport: Viewport.fromMap(json["viewport"]),
        bounds:
            json["bounds"] == null ? null : Viewport.fromMap(json["bounds"]),
      );

  Map<String, dynamic> toMap() => {
    "location": location.toMap(),
    "location_type": locationType,
    "viewport": viewport.toMap(),
    "bounds": bounds?.toMap(),
  };
}
