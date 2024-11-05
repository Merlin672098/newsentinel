import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener cloud_firestore en tu pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart'; // Para obtener el usuario autenticado
import 'package:newsentinel/constants/global_variables.dart';

class PerfilScreen extends StatefulWidget {
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Variable para almacenar los datos del usuario
  Map<String, dynamic>? userData;

  // Obtener el usuario actual logeado
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Llamamos a la función para obtener los datos del usuario
    fetchUserData();
  }

  // Función para obtener los datos del usuario de Firestore
  Future<void> fetchUserData() async {
    if (currentUser != null) {
      try {
        // Consulta a la colección 'users' usando el ID del usuario autenticado
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>?;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  // Método para generar un campo de datos con borde
  Widget buildDataField(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: GlobalVariables.primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: GlobalVariables.greyBackgroundCOlor),
        ),
        backgroundColor: GlobalVariables.secondaryColor,
      ),
      body: userData == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: Colors.black,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          userData!['photoURL'] ??
                              'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png',
                        ),
                        radius: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          buildDataField(
                              'Nombre:', userData!['displayName'] ?? 'No disponible'),
                          buildDataField(
                              'Email:', userData!['email'] ?? 'No disponible'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Datos del Perfil:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Usando Row para distribuir los campos en la misma fila
                    Row(
                      children: [
                        Expanded(
                          child: buildDataField('Nombre:', 'Juan'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: buildDataField('Apellido:', 'Pérez'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: buildDataField('Tipo de Sangre:', 'O+'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: buildDataField('Asegurado:', 'Sí'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: buildDataField('Num. Ref:', '123456789'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: buildDataField(
                              'Suscripción:', 'Activa'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Servicios Asociados:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildDataField('Nombre:', 'Servicio Veterinario Tarija'),
                    buildDataField('Tipo:', 'Veterinaria'),
                    buildDataField('Ubicación:', 'Calle 123, Zona Centro'),
                    buildDataField('Departamento:', 'Tarija'),
                    buildDataField('Teléfono:', '789654123'),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
