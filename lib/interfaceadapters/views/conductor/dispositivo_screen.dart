/*import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DispositivosScreen extends StatefulWidget {
  @override
  _DispositivosScreenState createState() => _DispositivosScreenState();
}

class _DispositivosScreenState extends State<DispositivosScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> scanResults = [];

  // Escanear dispositivos
  void scanForDevices() async {
    setState(() {
      scanResults.clear();
    });

    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    }).onDone(() {
      print('Escaneo finalizado');
    });
  }

  // Conectar al dispositivo
  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      // Aquí puedes agregar lógica para obtener características y servicios del dispositivo
      print('Conectado al dispositivo: ${device.name}');
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dispositivos BLE'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: scanForDevices,
          ),
        ],
      ),
      body: scanResults.isEmpty
          ? Center(child: Text('Presiona el ícono de búsqueda para escanear'))
          : ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final result = scanResults[index];
                return ListTile(
                  title: Text(result.device.name.isNotEmpty
                      ? result.device.name
                      : 'Dispositivo sin nombre'),
                  subtitle: Text(result.device.id.toString()),
                  onTap: () {
                    flutterBlue.stopScan();
                    connectToDevice(result.device);
                  },
                );
              },
            ),
    );
  }
}
*/