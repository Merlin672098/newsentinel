import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:newsentinel/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../domain/entities/ubicacion.dart';

Future<Position> _requestPermission() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('La ubi no esta disponible');
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Los permisos fueron denegados');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('La ubicaion esta permanentementedenegada');
  }
  var status = await Permission.location.request();
  if (status.isGranted) {
    print('Permiso de ubicación concedido');
  } else {
    print('Permiso de ubicación denegado');
  }
  return await Geolocator.getCurrentPosition();
}
Future<void> requestAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  //User? currentUser = await getCurrentUser();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: false,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: false,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        final position = await _getLocation();
        flutterLocalNotificationsPlugin.show(
          888,
          'New Sentinel',
          'Su ubicacion es $position',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }

    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    final position = await _getLocation();
    //enviarUbicacion(position);
    _writeToFirebase(device, position);
    _writeToFirebase2(device, position);
    //API
    //await _writeToFirebase(device, position);
    print('FLUTTER BACKGROUND SERVICE: $position.latitude');
    service.invoke(
      'update',
      {
        "device": device,
        "current_location": {
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
      },
    );
  });
}
/*
Future<User?> getCurrentUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user;
}*/

Future<void> _writeToFirebase(String? device, Position position) async {
  User? user = FirebaseAuth.instance.currentUser;

  try {
    await FirebaseFirestore.instance.collection('location').doc(user?.uid).set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'linea': 'CE8C2BasK0YDFCEIcMd3',
      'name': 'prueba',
      'userId': user?.uid,
    }, SetOptions(merge: true));

    print('mandando ando');
  } catch (e) {
    print('Error : $e');
  }
}

Future<void> _writeToFirebase2(String? device, Position position) async {
  User? user = FirebaseAuth.instance.currentUser;

  try {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('prueba2').doc(user?.uid);

    DocumentSnapshot docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      List<dynamic> currentLocations =
          (docSnapshot.data() as Map<String, dynamic>)['locations'];

      List<dynamic> updatedLocations = [
        ...currentLocations,
        _createGeoPoint(position)
      ];

      await docRef.update({
        'locations': updatedLocations,
      });

      print('Nueva posición agregada');
    } else {
      await docRef.set({
        'locations': [_createGeoPoint(position)],
        'linea': 'CE8C2BasK0YDFCEIcMd3',
        'name': 'prueba',
        'userId': user?.uid,
        //variable de prueba para saber si se completo el recorrido
        'recorridoCompleto': false
      });
      String createdDocId = docRef.id;
      print('Documento creado para la prueba idk $createdDocId');
      String storedDocId = createdDocId;
      

      print('Documento creado');
    }
  } catch (e) {
    print('Error : $e');
  }
}

GeoPoint _createGeoPoint(Position position) {
  return GeoPoint(position.latitude, position.longitude);
}

Future<Position> _getLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Location services are disabled.';
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permissions are denied.';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied, we cannot request permissions.';
  }

  return await Geolocator.getCurrentPosition();
}

Future<void> enviarUbicacion(Position position) async {
  WebSocketChannel channel;

  try {
    Map<String, dynamic> posicionMapa = {
      'latitud': position.latitude,
      'longitud': position.longitude,
      'linea': 'CE8C2BasK0YDFCEIcMd3',
      'name': 'prueba',
      'userId': 'GK75zf08BNZipZibFjGpVJbQ5W93',
    };
    //String posicionJson = jsonEncode(posicionMapa);
    String mensaje2 = 'hola2';
    channel = WebSocketChannel.connect(
        Uri.parse('ws://nfc.api.dev.404.codes/api/auth'));
    //nfc.api.dev.404.code/api/auth
    channel.sink.add(mensaje2);

    channel.stream.listen((message) {
      print(message);
      channel.sink.close();
    });
  } catch (e) {
    print(e);
  }
}

class Sepuedebanda extends StatefulWidget {
  const Sepuedebanda({Key? key}) : super(key: key);

  @override
  State<Sepuedebanda> createState() => _SepuedebandaState();
}

class _SepuedebandaState extends State<Sepuedebanda> {
  String text = "Detener Servicio";
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
    initializeService();
    _requestPermission();
    requestAlarmPermission();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'UBICACION',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StreamBuilder<Map<String, dynamic>?>(
                  stream: FlutterBackgroundService().on('update'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final data = snapshot.data!;
                    String? device = data["device"];
                    Map<String, dynamic>? locationData = data["current_location"];

                    if (device == null || locationData == null) {
                      return Center(
                        child: Text('Error: Datos no disponibles'),
                      );
                    }

                    double? latitude = locationData["latitude"];
                    double? longitude = locationData["longitude"];

                    if (latitude == null || longitude == null) {
                      return Center(
                        child: Text('Error: Coordenadas no disponibles'),
                      );
                    }

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Dispositivo: $device',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Latitud: $latitude\nLongitud: $longitude',
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text("Modo en Primer Plano"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsForeground");
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.pause),
                  label: Text("Modo en Segundo Plano"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsBackground");
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.power_settings_new),
                  label: Text(text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () async {
                    final service = FlutterBackgroundService();
                    var isRunning = await service.isRunning();
                    if (isRunning) {
                      service.invoke("stopService");
                    } else {
                      service.startService();
                    }

                    setState(() {
                      text = isRunning ? 'Iniciar Servicio' : 'Detener Servicio';
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
