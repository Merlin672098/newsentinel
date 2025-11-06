import 'package:flutter/material.dart';


String uri = 'http://192.168.0.18:3000';
String uri2 = 'ws://192.168.0.18:3000';

var defaultBackgroundColor = Color.fromARGB(255, 255, 255, 255);
var appBarColor = Colors.grey[900];
var myAppBar = AppBar(
  backgroundColor: Color.fromARGB(255, 0, 42, 77),
  title: const Text(' '),
  centerTitle: false,
);
var drawerTextColor = TextStyle(
  color: Colors.grey[600],
);
var tilePadding = const EdgeInsets.only(left: 8.0, right: 8, top: 8);
var myDrawer = Drawer(
  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
  elevation: 0,
  child: Column(
    children: [
      DrawerHeader(
        child: Image.asset(
          'assets/logoBus.png',
          width: 164,
          height: 164,
        ),
      ),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(0),
        ),
        child: ListTile(
          leading: const Icon(Icons.home),
          title: Text(
            'D A S H B O A R D',
            style: drawerTextColor,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(0),
        ),
        child: ListTile(
          leading: const Icon(Icons.settings),
          title: Text(
            'S E T T I N G S',
            style: drawerTextColor,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(0),
        ),
        child: ListTile(
          leading: const Icon(Icons.info),
          title: Text(
            'A B O U T',
            style: drawerTextColor,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          //FirebaseAuth.instance.signOut();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(0),
        ),
        child: ListTile(
          leading: const Icon(Icons.logout),
          title: Text(
            'L O G O U T',
            style: drawerTextColor,
          ),
        ),
      ),
    ],
  ),
);
