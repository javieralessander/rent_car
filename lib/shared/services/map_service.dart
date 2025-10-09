import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/models/maps/maps.dart';
import '../dialogs/dialog_permission.dart';

class MapService extends ChangeNotifier {
  static const baseUrl = '';

  CameraPosition? posicionInicial;
  Position? posicionUser;
  CameraPosition? locationDevice;
  bool ubicacionActiva = false;

  MapService() {
    posicionInicial = const CameraPosition(
      target: LatLng(18.48753142359998, -69.92988547421308),
      zoom: 13.5,
    );
  }

  List<Prediction> prediction = [];

  bool _searching = false;
  bool get searching => _searching;
  set searching(bool value) {
    _searching = value;
    notifyListeners();
  }

  Future<Position?> getCurrentLocation(BuildContext context) async {
    final status = await Geolocator.requestPermission();
    if (status == LocationPermission.always ||
        status == LocationPermission.whileInUse) {
      posicionUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      ubicacionActiva = true;

      posicionInicial = CameraPosition(
        target: LatLng(posicionUser!.latitude, posicionUser!.longitude),
        zoom: 16.5,
      );
      locationDevice = CameraPosition(
        target: LatLng(posicionUser!.latitude, posicionUser!.longitude),
        zoom: 16.5,
      );

      notifyListeners();
      return posicionUser;
    } else {
      await Geolocator.requestPermission();

      if (status != LocationPermission.always ||
          status != LocationPermission.whileInUse) {
        // ignore: use_build_context_synchronously
        await _handlePermissionDeniedOrDeniedForever(context);
        return null;
      }
      return null;
    }
  }

  Future<void> _handlePermissionDeniedOrDeniedForever(
    BuildContext context,
  ) async {
    showPermission(
      context,
      'Para mejorar tu experiencia y proporcionarte un mejor servicio, te sugerimos permitir el acceso a tu ubicación.',
      [
        TextButton(
          child: const Text('cerrar', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
            // getCurrentLocation(context);
          },
        ),
        TextButton(
          onPressed: () async {
            await openAppSettings();
          },
          child: const Text('Ajustes', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<Place?> getPlacemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // try {
    //   final response = await http.get(Uri.parse(
    //       '${Environment.googleMapsApiUrl}/geocode/json?latlng=$latitude,$longitude&key=${Environment.androidGoogleKey}&language=es'));

    //   final placemarkResponse = PlacemarkResponse.fromJson(response.body);
    //   final place = placemarkResponse.results[0];

    //   return place;
    // } catch (e) {
    //   // print('Error al obtener la dirección');
    // }
    return null;
  }

  //Buscar places por nombre
  Future<List<Prediction>?> fetchSuggestions(
    String input,
    String sessionToken,
  ) async {
    // try {
    //   final response = await http.get(Uri.parse(
    //       '${Environment.googleMapsApiUrl}/place/autocomplete/json?input=$input&components=country:do&types=geocode|establishment&language=es&key=${Environment.androidGoogleKey}&sessiontoken=$sessionToken'));

    //   final suggestionResponse = SuggestionResponse.fromJson(response.body);
    //   prediction = suggestionResponse.predictions;
    //   notifyListeners();
    //   return prediction;
    // } catch (e) {
    //   print(e);
    //   return null;
    // }
    return null;
  }

  Future<LatLng?> getLocationFromAddress(String placeId) async {
    // try {
    //   final response = await http.get(Uri.parse(
    //       '${Environment.googleMapsApiUrl}/geocode/json?place_id=$placeId&key=${Environment.androidGoogleKey}'));

    //   final locationResponse = LocationResponse.fromJson(response.body);

    //   double latitude = locationResponse.results[0].geometry.location.lat;
    //   double longitude = locationResponse.results[0].geometry.location.lng;

    //   // lastLatLng = LatLng(latitude, longitude);
    //   return LatLng(latitude, longitude);
    // } catch (e) {
    //   print(e);
    return null;
    //   }
  }
}
