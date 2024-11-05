import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newsentinel/constants/constants.dart';
import 'package:newsentinel/constants/global_variables.dart';
import 'package:newsentinel/interfaceadapters/provider/user.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ListarRutasScreen extends StatefulWidget {
  final Function(int) onNavigate;

    const ListarRutasScreen({required this.onNavigate, Key? key}) : super(key: key);

  @override
  _ListarRutasScreenState createState() => _ListarRutasScreenState();
}

class _ListarRutasScreenState extends State<ListarRutasScreen> {
  late WebSocketChannel channel;
  List<dynamic> data = [];
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    try {
      channel = WebSocketChannel.connect(Uri.parse('$uri2/rutas'));
      channel.stream.listen((event) {
        try {
          //String idconductor = Provider.of<UserProvider>(context, listen: false).user.id;
          //String idconductor = Provider.of<UserProvider>(context, listen: false).user.id;
            String idconductor = UserProvider().getUserId();

          //String idconductor = '65f76700985dd0627616e8b6';
         // print('aaaaa $idconductor');
          final jsonData = json.decode(event);
          List<dynamic> filteredData = jsonData
              .where((item) => item['idConductor'] == idconductor)
              .toList();
          setState(() {
            data = filteredData;
            _isConnecting = false;
          });
          //print('Datos recibidos: $data');
        } catch (e) {
          print('Error decoding JSON: $e');
        }
      }, onError: (error) {
        print('WebSocket error: $error');
        setState(() {
          _isConnecting = false;
        });
      }, onDone: () {
        print('WebSocket connection closed');
        setState(() {
          _isConnecting = false;
        });
      });
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.secondaryColor,
        title: const Text('Lista de Rutas', 
        style: TextStyle(color: GlobalVariables.greyBackgroundCOlor)),
      ),
      body: _isConnecting
          ? const Center(child: CircularProgressIndicator())
          : _buildListView(),
    );
  }

  Widget _buildListView() {
  if (data.isEmpty) {
    return const Center(child: Text('No hay datos disponibles.'));
  } else {
    return Container(
      color: GlobalVariables.secondaryColor, 
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final ruta = data[index];
          String idRuta = ruta['_id'] ?? '';
          String nombre = ruta['nombre'] ?? '';
          String horaInicio = ruta['horaInicio'] ?? '';
          String estado = ruta['estado'] ?? '';

          return GestureDetector(
            onTap: () {
              /*Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MapaScreen(idRuta),
              ));*/
            },
            child: Card(
              color: GlobalVariables.primaryColor,
              elevation: 5,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: GlobalVariables.secondaryColor,
                  child: Icon(Icons.route, color: GlobalVariables.greyBackgroundCOlor),
                ),
                title: Text('Ruta: $nombre',
                    style: const TextStyle(color: GlobalVariables.secondaryColor)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: $idRuta',
                        style: const TextStyle(color: GlobalVariables.secondaryColor)),
                    Text('Hora de Inicio: $horaInicio',
                        style: const TextStyle(color: GlobalVariables.secondaryColor)),
                    Text('Estado: $estado',
                        style: const TextStyle(color: GlobalVariables.secondaryColor)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
