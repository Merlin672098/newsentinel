import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:newsentinel/constants/global_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapaViaje extends StatefulWidget {
  @override
  _MapaViajeState createState() => _MapaViajeState();
}

class _MapaViajeState extends State<MapaViaje> {
  late GoogleMapController mapController;
  Marker? marcadorDestino;
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
  LatLng? destinoSeleccionado;
LatLng ubicacionActual = LatLng(-21.531417296871105, -64.73361248624106);
  BitmapDescriptor? customIcon;


  @override
  void initState() {
    super.initState();
    _fetchUbicacionActual();
    _createCustomMarker(); // Llamada a la función para crear el marcador personalizado
  }


Future<void> _fetchUbicacionActual() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Usuario no autenticado.');
      return;
    }

    final docSnapshot = await FirebaseFirestore.instance
        .collection('location')
        .doc(user.uid)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      double latitude = data?['latitude'];
      double longitude = data?['longitude'];

      setState(() {
        ubicacionActual = LatLng(latitude, longitude);
      });
    } else {
      print('No se encontró la ubicación del usuario.');
    }
  } catch (e) {
    print('Error obteniendo ubicación desde Firestore: $e');
  }
}

  Future<void> _createCustomMarker() async {
    // Cargar las imágenes, en este caso el marcador base y la imagen cargada
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Dibujar el marcador de fondo (puedes cambiar color o forma)
    final Paint paint = Paint()
      ..color = Colors
          .transparent; // Puedes usar transparente para solo mostrar la imagen circular
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0.0, 0.0, 100.0, 100.0), Radius.circular(50.0)),
      paint,
    );

    // Cargar la imagen personalizada desde la URL
    final Uint8List imageData = await _getBytesFromNetworkImage(
        'https://lh3.googleusercontent.com/a/ACg8ocKPeTQB8dOXMx7hM9yc0-kcLaM0QnkwCmChwB1Ww8Bt_EhRdzf2=s96-c');
    final ui.Image image = await loadImage(imageData);

    // Hacer la imagen circular usando un path circular
    final Path circularPath = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(50, 50), radius: 50)); // Imagen circular

    // Clip (recortar) la imagen dentro del marcador circular
    canvas.clipPath(circularPath);

    // Dibujar la imagen personalizada dentro del marcador, haciendo que cubra toda la parte blanca
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0.0, 0.0, image.width.toDouble(),
          image.height.toDouble()), // Imagen completa
      Rect.fromLTWH(0.0, 0.0, 100.0, 100.0), // Cubrir toda el área del marcador
      Paint(),
    );

    final ui.Image markerAsImage =
        await pictureRecorder.endRecording().toImage(100, 100);
    final ByteData? byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    setState(() {
      customIcon = BitmapDescriptor.fromBytes(uint8List);
    });
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<Uint8List> _getBytesFromNetworkImage(String url) async {
    final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load("");
    return data.buffer.asUint8List();
  }

  void _onMapCreated(GoogleMapController controller) {
    // ignore: deprecated_member_use
    controller.setMapStyle(GlobalVariables.darkMapStyle);
    mapController = controller;
  }

  void _onMapTap(LatLng position) {
    setState(() {
      marcadorDestino = Marker(
        markerId: MarkerId('marcadorDestino'),
        position: position,
        draggable: false,
        icon: customIcon ?? BitmapDescriptor.defaultMarker,
      );
      destinoSeleccionado = position;
    });
  }

  void _dibujarRuta() async {
    if (destinoSeleccionado != null) {
      final request = PolylineRequest(
        origin:
            PointLatLng(ubicacionActual!.latitude, ubicacionActual!.longitude),
        destination: PointLatLng(
            destinoSeleccionado!.latitude, destinoSeleccionado!.longitude),
        mode: TravelMode.driving,
      );

      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyDSZKy4lXQKNt5oPlzYPCsTM60e3qau--U',
        request: request,
      );

      if (result.status == 'OK' && result.points.isNotEmpty) {
        polylineCoordinates.clear();
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        setState(() {
          polylines.add(Polyline(
            polylineId: PolylineId('ruta'),
            color: GlobalVariables.primaryColor,
            width: 5,
            points: polylineCoordinates,
          ));
        });
      } else {
        print('No se pudo obtener la ruta.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/a/ACg8ocKPeTQB8dOXMx7hM9yc0-kcLaM0QnkwCmChwB1Ww8Bt_EhRdzf2=s96-c'), // Reemplaza con la URL de tu imagen
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                const Text(
                  'Nombre del Usuario',
                  style: TextStyle(color: GlobalVariables.greyBackgroundCOlor),
                ),
                Text(
                  _calcularDistancia(),
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: GlobalVariables.secondaryColor,
        iconTheme: IconThemeData(
          color: GlobalVariables.greyBackgroundCOlor,
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _onMapTap,
            initialCameraPosition: CameraPosition(
              target: ubicacionActual!,
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: MarkerId('ubicacionActual'),
                position: ubicacionActual!,
                infoWindow: InfoWindow(title: 'Ubicación Actual'),
                draggable: false,
                icon: customIcon ??
                    BitmapDescriptor.defaultMarker, // Marcador personalizado
              ),
              if (marcadorDestino != null) marcadorDestino!,
            },
            polylines: polylines,
          ),
          Positioned(
            bottom: 20,
            left: 80,
            right: 80,
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _dibujarRuta,
                style: ElevatedButton.styleFrom(
                  foregroundColor: GlobalVariables.secondaryColor,
                  backgroundColor: GlobalVariables.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Confirmar y Dibujar Ruta'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calcularDistancia() {
    if (destinoSeleccionado != null) {
      double distancia = _calcularDistanciaEnKilometros(
        ubicacionActual!.latitude,
        ubicacionActual!.longitude,
        destinoSeleccionado!.latitude,
        destinoSeleccionado!.longitude,
      );
      return '${distancia.toStringAsFixed(2)} km';
    } else {
      return 'Distancia desconocida';
    }
  }

  double _calcularDistanciaEnKilometros(
      double lat1, double lon1, double lat2, double lon2) {
    const double rad = 0.017453292519943295;
    double dlat = (lat2 - lat1) * rad;
    double dlon = (lon2 - lon1) * rad;
    double a = 0.5 -
        cos(dlat) / 2 +
        cos(lat1 * rad) * cos(lat2 * rad) * (1 - cos(dlon)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
