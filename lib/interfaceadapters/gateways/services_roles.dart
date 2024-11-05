import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsentinel/interfaceadapters/conductor_main.dart';
import 'package:newsentinel/interfaceadapters/admin_main.dart';


class VerificacionRolWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;

      CollectionReference usuariosCollection =
          FirebaseFirestore.instance.collection('users');

      return StreamBuilder<DocumentSnapshot>(
        stream: usuariosCollection.doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            var data = snapshot.data!.data() as Map<String, dynamic>?;

            if (data != null && data['role'] != null) {
              String rol = data['role'];

              if (rol == 'conductor') {
                return const ConductorMain();
              } else if (rol == 'admin') {
                return const AdminMain();
              } /*else if (rol == 'padre') {
                return const PadreMain();
              } else if (rol == 'inspector') {
                return const EstudianteMain();
              } else if (rol == 'admin') {
                return const EstudianteMain();
              }*/ else {
                return Text('Rol desconocido: $rol');
              }
            } else {
              return const Text(
                  'Campo "rol" no encontrado en los datos del usuario');
            }
          } else {
            return const Text('Usuario no encontrado en la colección "jasyd"');
          }
        },
      );
    } else {
      return const Text('Usuario no autenticado');
    }
  }
}

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getRoles() async {
  List roles = [];

  QuerySnapshot querySnapshot = await db.collection('role').get();

  for (var doc in querySnapshot.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final rol = {
      "id": doc.id,
      "nombre": data['nombre'],
    };
    roles.add(rol);
  }
  return roles;
}

Future<List<String>> getSuggestions(String query) async {
  final List roles = await getRoles();

  final List<String> suggestions = roles
      .where((rol) => rol['nombre'].toLowerCase().contains(query.toLowerCase()))
      .map((rol) => rol['nombre'] as String)
      .toSet()
      .toList();

  return suggestions;
}

/*
class RolRepositoryImpl implements RolRepository {
  @override
  Future create(Rol rol) async {
    final docUser = FirebaseFirestore.instance.collection('rol').doc();

    rol.id = docUser.id;
    final json = rol.toJson();

    await docUser.set(json);
  }

  @override
  Future update(Rol rol) async {
    final docUser = FirebaseFirestore.instance.collection('rol').doc(rol.id);

    final json = rol.toJson();

    await docUser.update(json);
  }
}
*/
Future<void> updateRol(String id, String nombre) async {
  await db.collection("rol").doc(id).update({
    "nombre": nombre,
  });
}

Future<void> deleteRol(String id) async {
  await db.collection("rol").doc(id).update({
    "borrado": true,
  });
}
