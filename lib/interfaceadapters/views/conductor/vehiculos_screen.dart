/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsentinel/constants/global_variables.dart';

class VehiculosScreen extends StatefulWidget {
  @override
  _VehiculosScreenState createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final CollectionReference vehiculosCollection =
      FirebaseFirestore.instance.collection('vehiculos');
  User? currentUser;

  @override
  void initState() {
    super.initState();
    // Obtener el usuario autenticado
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: GlobalVariables.secondaryColor, 

      appBar: AppBar(
        title: Text('Vehículos'),
        backgroundColor: GlobalVariables.primaryColor,
      ),
      body: currentUser == null
          ? Center(child: Text('No estás autenticado.'))
          : StreamBuilder(
              stream: vehiculosCollection
                  .where('idUser', isEqualTo: currentUser!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No se encontraron vehículos.'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  
                    return Card(
                      color: GlobalVariables.primaryColor,
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(
                          data['imagenURL'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(data['marca'] ?? 'Sin marca'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Modelo: ${data['Modelo'] ?? 'Sin modelo'}',
                            ),
                            Text('Color: ${data['Color'] ?? 'Sin color'}'),
                            Text('Placa: ${data['Placa'] ?? 'Sin color'}'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}*/

// lib/interfaceadapters/views/conductor/vehiculos_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newsentinel/constants/global_variables.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/QRScreen.dart';

/// Pantalla de Vehículos
/// - Muestra vehículos del usuario (colección 'vehiculos').
/// - Botón "Registrar" -> abre lector QR -> devuelve deviceId -> abre formulario para agregar vehículo.
/// - Evita duplicados locales y pregunta al backend (opcional) si el deviceId ya está registrado.
/// - Permite enlazar múltiples vehículos a distintos deviceIds (o varios vehículos por dispositivo si backend lo permite).
class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({Key? key}) : super(key: key);

  @override
  _VehiculosScreenState createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final CollectionReference vehiculosCollection =
      FirebaseFirestore.instance.collection('vehiculos');

  User? currentUser;
  final ImagePicker _picker = ImagePicker();

  // Lista local de deviceIds escaneados (simulación). Permite varios devices.
  List<String> dispositivosEscaneados = [];

  // Form controllers para registrar vehículo
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _colorController = TextEditingController();
  final _placaController = TextEditingController();
  String? _currentDeviceId;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  /// Inicia el flujo: abrir lector QR y procesar resultado.
  Future<void> _startQrAndRegisterFlow() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerTab()),
    );

    if (result == null || result.isEmpty) {
      // Cancelado o nada leído
      return;
    }

    final String deviceId = result.trim();

    // 1) Evitar duplicados locales
    if (dispositivosEscaneados.contains(deviceId)) {
      _showMessage('Este dispositivo ya fue escaneado en esta sesión.');
      return;
    }

    // 2) Opcional (recomendado): verificar con backend si deviceId ya existe en la DB
    //    Esto evita race condition entre usuarios. Aquí dejamos el marcador para el backend.
    // TODO BACKEND: reemplazar por llamada real a API que verifique si el deviceId ya está asociado
    // Example (frontend placeholder):
    // final resp = await http.get(Uri.parse('$apiBase/devices/exists?deviceId=$deviceId'));
    // if (resp.statusCode == 200 && resp.body == 'true') { /* ya existe */ }

    // Para demo/front, también chequeamos Firestore localmente (cliente) como prevalidación:
    final existing = await vehiculosCollection.where('deviceId', isEqualTo: deviceId).limit(1).get();
    if (existing.docs.isNotEmpty) {
      _showMessage('Este dispositivo ya está registrado en la plataforma.');
      return;
    }

    // 3) Si pasa validaciones, añadimos a la lista local
    setState(() => dispositivosEscaneados.add(deviceId));

    // 4) Abrir formulario de registro con deviceId pre-llenado
    _currentDeviceId = deviceId;
    await _mostrarFormRegistrar(deviceId: deviceId);
  }

  /// Mostrar formulario para registrar vehículo con el deviceId ya conocido.
  Future<void> _mostrarFormRegistrar({required String deviceId}) async {
    // limpiar
    _marcaController.clear();
    _modeloController.clear();
    _colorController.clear();
    _placaController.clear();
    _localImagePath = null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GlobalVariables.secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Registrar vehículo', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // imagen preview + seleccionar
                  GestureDetector(
                    onTap: _pickVehicleImage,
                    child: Container(
                      width: 140,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                        image: _localImagePath != null
                            ? DecorationImage(image: FileImage(File(_localImagePath!)), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _localImagePath == null
                          ? const Center(child: Icon(Icons.camera_alt_outlined, color: Colors.white70))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(_marcaController, 'Marca', required: true),
                  _buildTextField(_modeloController, 'Modelo'),
                  _buildTextField(_colorController, 'Color'),
                  _buildTextField(_placaController, 'Placa', required: true),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Device ID:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GlobalVariables.greyBackgroundCOlor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(deviceId, style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                // Si cancela, removemos el deviceId de la lista local
                setState(() => dispositivosEscaneados.remove(deviceId));
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.primaryColor,
                foregroundColor: GlobalVariables.secondaryColor,
              ),
              child: const Text('Registrar'),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                // Guardar en Firestore (cliente) y marcar TODO para backend storage
                await _guardarVehiculo(deviceId: deviceId);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController c, String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null : null,
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  /// Seleccionar imagen desde galería (preview local).
  Future<void> _pickVehicleImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _localImagePath = picked.path);
  }

  /// Guarda el vehículo en Firestore (cliente). Marca TODO donde backend debe subir imagen y retornar imagenURL.
  Future<void> _guardarVehiculo({required String deviceId}) async {
    if (currentUser == null) {
      _showMessage('Usuario no autenticado', isError: true);
      return;
    }

    try {
      // TODO BACKEND: Aquí podrían:
      // 1) Recibir el archivo (localImagePath) vía endpoint y subirlo al storage.
      // 2) Devolver `imagenURL`.
      // 3) Retornar esa imagenURL que se guardará en el documento `vehiculos`.

      // Por ahora guardamos localImagePath para demo/local testing
      final docData = <String, dynamic>{
        'idUser': currentUser!.uid,
        'marca': _marcaController.text.trim(),
        'Modelo': _modeloController.text.trim(),
        'Color': _colorController.text.trim(),
        'Placa': _placaController.text.trim(),
        'deviceId': deviceId,
        'imagenURL': '', // TODO BACKEND: reemplazar con URL devuelta por storage
        'localImagePath': _localImagePath ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await vehiculosCollection.add(docData);

      _showMessage('Vehículo registrado correctamente');

      // Opcional: informar al backend el deviceId que ahora está ligado
      // TODO BACKEND: llamar endpoint para notificar asociación (ej POST /devices/link)
      // await Api.linkDevice(deviceId, currentUser!.uid);

    } catch (e) {
      _showMessage('Error al registrar vehículo: $e', isError: true);
      // En caso de error, podrías remover deviceId localmente para permitir reintento
      setState(() => dispositivosEscaneados.remove(deviceId));
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.redAccent : null),
    );
  }

  /// Tarjeta superior "Registrar dispositivo / vehículo"
  Widget _buildRegisterCard() {
    return GestureDetector(
      onTap: _startQrAndRegisterFlow,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: GlobalVariables.greyBackgroundCOlor, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: GlobalVariables.secondaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: GlobalVariables.primaryColor),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Registrar dispositivo / vehículo',
                style: TextStyle(color: GlobalVariables.primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.qr_code_scanner, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  /// Tarjeta UI para cada vehículo
  Widget _buildVehiculoCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final imagenURL = data['imagenURL'] ?? '';
    final localImagePath = data['localImagePath'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color.fromARGB(255, 59, 59, 59), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade800,
              image: imagenURL.toString().isNotEmpty
                  ? DecorationImage(image: NetworkImage(imagenURL), fit: BoxFit.cover)
                  : (localImagePath.toString().isNotEmpty ? DecorationImage(image: FileImage(File(localImagePath)), fit: BoxFit.cover) : null),
            ),
            child: (imagenURL.toString().isEmpty && localImagePath.toString().isEmpty)
                ? const Icon(Icons.directions_car, color: Colors.white70)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data['marca'] ?? 'Sin marca', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Placa: ${data['Placa'] ?? '---'}', style: const TextStyle(color: Colors.white70)),
              Text('Device: ${data['deviceId'] ?? '---'}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
            onPressed: () {
              // TODO: navegar a detalle del vehículo / acciones
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.secondaryColor,
      appBar: AppBar(
        title: const Text('Vehículos', style: TextStyle(color: Colors.white)),
        backgroundColor: GlobalVariables.secondaryColor,
      ),
      body: currentUser == null
          ? const Center(child: Text('No estás autenticado.', style: TextStyle(color: Colors.white)))
          : StreamBuilder<QuerySnapshot>(
              stream: vehiculosCollection.where('idUser', isEqualTo: currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                return ListView(
                  children: [
                    _buildRegisterCard(),
                    if (docs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Text('No se encontraron vehículos.', style: TextStyle(color: Colors.white70)),
                      )
                    else
                      ...docs.map((d) => _buildVehiculoCard(d)).toList(),
                  ],
                );
              },
            ),
    );
  }
}
