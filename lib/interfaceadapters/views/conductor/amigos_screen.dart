import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsentinel/constants/constants.dart';
import 'package:newsentinel/constants/global_variables.dart';
import 'package:newsentinel/interfaceadapters/gateways/amigos_service.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/detalle_amigo_screen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AmigosScreen extends StatefulWidget {
  @override
  _AmigosScreenState createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final AmigosService amigosService = AmigosService();
  late WebSocketChannel channel;
  List<dynamic> data = [];
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _connectToWebSocket();
      listarAmigos();
    }
  }

  void listarAmigos() {
    if (currentUser != null) {
      amigosService.listarMisAmigos(currentUser!.uid);
    }
  }

  void _connectToWebSocket() {
    try {
      channel = WebSocketChannel.connect(Uri.parse('$uri2/amigos'));
      channel.stream.listen((event) {
        try {
          final jsonData = json.decode(event) as List<dynamic>;
          jsonData.sort((a, b) => (a['id']?.compareTo(b['id']) ?? 0));
          setState(() {
            data = jsonData;
            _isConnecting = false;
          });
        } catch (e) {
          print('Error decoding JSON: $e');
        }
      }, onError: (error) {
        print('WebSocket error: $error');
        setState(() => _isConnecting = false);
      }, onDone: () {
        print('WebSocket connection closed');
        setState(() => _isConnecting = false);
      });
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.secondaryColor, 
      appBar: AppBar(
        title: const Text(
          'Amigos', 
          style: TextStyle(color: GlobalVariables.greyBackgroundCOlor),
        ), 
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

          if (amigosIds.isEmpty) {
            return const Center(
              child: Text(
                'No tienes amigos agregados.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: amigosIds)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
              if (!usersSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleAmigoScreen(userId: userDoc.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

