// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';

// import '../../core/config/app_theme.dart';
// import '../../features/auth/services/services.dart';
// import '../../features/auth/widgets/custom_button.dart';
// import '../services/map_service.dart';

// class CustomGoogleMaps extends StatefulWidget {
//   static const String name = 'map';

//   const CustomGoogleMaps({super.key});

//   @override
//   State<CustomGoogleMaps> createState() => _CustomGoogleMapsState();
// }

// class _CustomGoogleMapsState extends State<CustomGoogleMaps> {
//   late GoogleMapController _mapController;
//   final TextEditingController _controllerTextField = TextEditingController();

//   bool _buttonEnabled = false;

//   @override
//   void initState() {
//     super.initState();
//     // Agrega un listener que se llamará cada vez que el texto cambie.
//     _controllerTextField.addListener(_onTextChanged);
//   }

//   void _onTextChanged() {
//     // Habilita el botón si el texto no está vacío; de lo contrario, lo deshabilita.
//     setState(() {
//       _buttonEnabled = _controllerTextField.text.isNotEmpty;
//     });
//   }

//   @override
//   void dispose() {
//     _controllerTextField.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     final centerDevice = getCenterDevice(context);

//     final mapService = Provider.of<MapService>(context);

//     //Buscar place en el mapa
//     getSuggestions(String search) {
//       final sessionToken = const Uuid().v4();
//       mapService.fetchSuggestions(search, sessionToken);
//     }

//     Future<void> checkCameraPosition() async {
//       await _mapController.getLatLng(ScreenCoordinate(
//         x: centerDevice[0].round(),
//         y: centerDevice[1].round(),
//       ));
//       setState(() {});
//     }

//     const textFieldBorder = UnderlineInputBorder(
//         borderSide: BorderSide(width: 2.5, color: AppColors.devtoCanvasColors));
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         appBar: AppBar(
//             automaticallyImplyLeading: false,
//             centerTitle: true,
//             elevation: 0,
//             backgroundColor: AppColors.white,
//             toolbarHeight: 35,
//             leading: IconButton(
//               icon: const Icon(
//                 CupertinoIcons.back,
//                 color: AppColors.devtoCanvasColors,
//               ),
//               onPressed: () {
//                 context.pop();
//               },
//             ),
//             title: const Text(
//               'Selecciona una ubicación',
//               style: TextStyle(
//                 color: AppColors.devtoPrimary,
//                 fontSize: 18,
//               ),
//             )),
//         resizeToAvoidBottomInset: false,
//         body: SafeArea(
//           child: Stack(
//             children: [
//               GoogleMap(
//                 mapType: MapType.normal,
//                 initialCameraPosition: mapService.posicionInicial!,
//                 myLocationEnabled: mapService.ubicacionActiva,
//                 myLocationButtonEnabled: false,
//                 onMapCreated: (GoogleMapController controller) {
//                   _mapController = controller;
//                 },
//                 onCameraIdle: () async {
//                   final position = await _mapController
//                       .getLatLng(ScreenCoordinate(
//                         x: centerDevice[0].round(),
//                         y: centerDevice[1].round(),
//                       ))
//                       .then((value) => value);

//                   setState(() {
//                     mapService
//                         .getPlacemarkFromCoordinates(
//                             position.latitude, position.longitude)
//                         .then((value) {
//                       if (value != null) {
//                         // direccion = value.formattedAddress;
//                         _controllerTextField.text = value.formattedAddress;
//                       }
//                     });
//                     checkCameraPosition();
//                   });
//                 },
//                 onCameraMove: (CameraPosition position) {
//                   mapService.posicionInicial = position;
//                 },
//                 zoomControlsEnabled: false,
//               ),
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: 44),
//                   child: Icon(
//                     Icons.location_pin,
//                     color: AppColors.devtoCanvasColors,
//                     size: 50,
//                   ),
//                 ),
//               ),
//               Container(
//                 height: mapService.searching
//                     ? null
//                     : MediaQuery.of(context).size.height * 0.12,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     stops: [0.7, 1],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Color.fromARGB(255, 255, 255, 255),
//                       Color.fromARGB(0, 255, 255, 255),
//                     ],
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     TextField(
//                         // key: mapKeyTextField,
//                         onTap: () {
//                           mapService.searching = true;
//                           setState(() {
//                             if (_controllerTextField.text.isNotEmpty) {
//                               getSuggestions(_controllerTextField.text);
//                             }
//                           });
//                         },
//                         controller: _controllerTextField,
//                         onChanged: (value) => {
//                               if (value.isNotEmpty) {getSuggestions(value)}
//                             },
//                         decoration: const InputDecoration(
//                             focusedBorder: textFieldBorder,
//                             border: textFieldBorder,
//                             errorBorder: textFieldBorder,
//                             enabledBorder: textFieldBorder,
//                             disabledBorder: textFieldBorder,
//                             focusedErrorBorder: textFieldBorder,
//                             contentPadding: EdgeInsets.zero,
//                             constraints: BoxConstraints(maxHeight: 35))),
//                     const SizedBox(height: 10),
//                     mapService.searching
//                         ? Container()
//                         : const Text(
//                             'Asegúrate de colocar el pin verde en el punto de entrega deseado, hasta que se complete el campo de texto.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontSize: 12),
//                           ),
//                     mapService.searching
//                         ? Expanded(
//                             child: ListView.builder(
//                               itemCount: mapService.prediction.length,
//                               itemBuilder: (context, index) => ListTile(
//                                   onTap: () async {
//                                     final LatLng? coordenadas = await mapService
//                                         .getLocationFromAddress(mapService
//                                             .prediction[index].placeId);

//                                     if (coordenadas != null) {
//                                       mapService.searching = false;
//                                       await _mapController.animateCamera(
//                                           CameraUpdate.newCameraPosition(
//                                               CameraPosition(
//                                                   zoom: 16.5,
//                                                   target: coordenadas)));
//                                     }
//                                   },
//                                   title: Text(
//                                       mapService.prediction[0].description)),
//                             ),
//                           )
//                         : Container(),
//                   ],
//                 ),
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                       vertical: size.height * 0.01,
//                       horizontal: size.width * 0.04),
//                   child: CustomButton(
//                     heightButton: 55,
//                     text: 'Agregar dirección',
//                     textFontSize: 18,
//                     textColor: AppColors.white,
//                     backgroundColor: _buttonEnabled
//                         ? AppColors.devtoCanvasColors
//                         : AppColors.gray,
//                     onTap: _buttonEnabled
//                         ? () {
//                             final registerService =
//                                 context.read<RegisterService>();

//                             context.read<RegisterService>().direction =
//                                 _controllerTextField.text;

//                             registerService.user.location = GeoPoint(
//                                 mapService.posicionInicial!.target.latitude,
//                                 mapService.posicionInicial!.target.longitude);

//                             context.pop();
//                             FocusScope.of(context).unfocus();
//                           }
//                         : null,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         floatingActionButton: mapService.ubicacionActiva == true
//             ? FutureBuilder<Position>(
//                 future: Geolocator.getCurrentPosition(
//                   desiredAccuracy: LocationAccuracy.bestForNavigation,
//                 ),
//                 builder:
//                     (BuildContext context, AsyncSnapshot<Position> snapshot) {
//                   return Padding(
//                     padding: EdgeInsets.only(bottom: size.height * 0.08),
//                     child: FloatingActionButton(
//                       elevation: 1,
//                       mini: true,
//                       backgroundColor: AppColors.white,
//                       child: const Icon(Icons.my_location_rounded,
//                           size: 26, color: AppColors.devtoCanvasColors),
//                       onPressed: () async {
//                         if (mapService.searching) {
//                           mapService.searching = false;

//                           FocusScope.of(context).unfocus();
//                           TextEditingController().clear();

//                           await Future.delayed(const Duration(seconds: 2));
//                         }

//                         if (mapService.ubicacionActiva == false) {
//                           // ignore: use_build_context_synchronously
//                           await mapService.getCurrentLocation(context);

//                           if (mapService.ubicacionActiva == true) {
//                             await _mapController.animateCamera(
//                                 CameraUpdate.newCameraPosition(CameraPosition(
//                                     target: LatLng(snapshot.data!.latitude,
//                                         snapshot.data!.longitude),
//                                     zoom: 20)));
//                           }
//                         } else {
//                           await _mapController.animateCamera(
//                               CameraUpdate.newCameraPosition(CameraPosition(
//                                   target: LatLng(snapshot.data!.latitude,
//                                       snapshot.data!.longitude),
//                                   zoom: 20)));
//                         }
//                       },
//                     ),
//                   );
//                   // }
//                 })
//             : null,
//       ),
//     );
//   }

//   List<double> getCenterDevice(context) {
//     double screenWidth = MediaQuery.of(context).size.width *
//         MediaQuery.of(context).devicePixelRatio;
//     double screenHeight = MediaQuery.of(context).size.height *
//         MediaQuery.of(context).devicePixelRatio;

//     double middleX = screenWidth / 2;
//     double middleY = screenHeight / 2;

//     return [middleX, middleY];
//   }
// }
