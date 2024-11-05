import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsentinel/constants/global_variables.dart';

class AmigosScreen extends StatefulWidget {
  @override
  _AmigosScreenState createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.secondaryColor, 
      appBar: AppBar(
        title: const Text('Amigos', style: TextStyle(color: GlobalVariables.greyBackgroundCOlor),), 
        backgroundColor: GlobalVariables.secondaryColor, 
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('amigos')
            .where('idUsuario', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> amigosSnapshot) {
          if (!amigosSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<String> amigosIds = amigosSnapshot.data!.docs
              .map((doc) => doc['idAmigo'].toString())
              .toList();

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: amigosIds)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
              if (!usersSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              const SizedBox(height: 20);
              return ListView.builder(
                itemCount: usersSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var userDoc = usersSnapshot.data!.docs[index];
                  return Card( 
                    color: GlobalVariables.primaryColor, 
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 5, 
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(userDoc['photoURL']),
                      ),
                      title: Text(
                        userDoc['displayName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: GlobalVariables.secondaryColor,
                        ),
                      ),
                      subtitle: Text(
                        userDoc['email'],
                        style: const TextStyle(
                          color: GlobalVariables.secondaryColor,
                           fontSize: 12
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        backgroundColor: GlobalVariables.primaryColor,
        child: const Icon(Icons.add, color: GlobalVariables.secondaryColor),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, 
    );
  }
}
