import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsentinel/constants/global_variables.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/mapa_viaje.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/viaje_mapa2.dart';

class ViajesScreen extends StatefulWidget {
  @override
  _ViajesScreenState createState() => _ViajesScreenState();
}

class _ViajesScreenState extends State<ViajesScreen> {
  // Obtén el ID del usuario actual
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.secondaryColor,
      appBar: AppBar(
        title: const Text('Mis Viajes', style: TextStyle(color: GlobalVariables.greyBackgroundCOlor)),
        backgroundColor: GlobalVariables.secondaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Consulta a la colección 'viajes' donde el campo 'idUser' sea igual al ID del usuario actual
        stream: FirebaseFirestore.instance
            .collection('viajes')
            .where('idUser', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          // Verifica si hay un error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Verifica si los datos están cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si no hay viajes
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No tienes viajes registrados'),
            );
          }

          // Construye la lista de viajes
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var viaje = snapshot.data!.docs[index];
              return Card( // Usamos una Card para darle un diseño más atractivo
                color: GlobalVariables.primaryColor, // Color de fondo de cada item
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Márgenes de los items
                elevation: 5, // Sombra de la Card
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: GlobalVariables.secondaryColor, // Fondo del CircleAvatar
                    child: Icon(
                      Icons.route, // Ícono de rutas
                      color: GlobalVariables.greyBackgroundCOlor, // Color del ícono
                    ),
                  ),
                  title: Text(
                    viaje['nombreDestino'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: GlobalVariables.secondaryColor, // Color del texto del nombre
                    ),
                  ),
                  subtitle: Text('Fecha: ${viaje['fecha']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: GlobalVariables.secondaryColor, // Color del texto del nombre
                    ),
                  ),
                  onTap: () {
                    // Navega al widget MapaViaje con la información del viaje seleccionado
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapaViaje2(
                          nombreDestino: viaje['nombreDestino'],
                          fecha: viaje['fecha'],
                          latitude: viaje['latitude'],
                          longitude: viaje['longitude'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapaViaje()),
          );
        },
        backgroundColor: GlobalVariables.primaryColor,
        child: const Icon(Icons.add, color: GlobalVariables.secondaryColor),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
