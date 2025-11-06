import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsentinel/constants/global_variables.dart';

class DetalleAmigoScreen extends StatelessWidget {
  final String userId;
  const DetalleAmigoScreen({required this.userId});

  void agregarContactoEmergencia(BuildContext context) {
    FirebaseFirestore.instance.collection('emergency_contacts').doc(userId).set({
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacto de emergencia guardado')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar contacto: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.secondaryColor, 
      appBar: AppBar(
        title: const Text(
          'Informacion Amigo',
          style: TextStyle(color: GlobalVariables.greyBackgroundCOlor),
        ), 
        backgroundColor: GlobalVariables.secondaryColor, 
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            return const Center(child: Text('No se encontraron datos del amigo.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userData['photoURL']),
                  radius: 50,
                ),
                const SizedBox(height: 20),
                Text(
                  userData['displayName'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Email: ${userData['email']}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => agregarContactoEmergencia(context),
                  child: const Text('Agregar como Contacto de Emergencia'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
