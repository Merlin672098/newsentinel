import 'package:flutter/material.dart';
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
}
