import 'package:flutter/material.dart';
import 'package:newsentinel/constants/global_variables.dart';

class DocumentosLegalesScreen extends StatefulWidget {
  @override
  _DocumentosLegalesScreenState createState() => _DocumentosLegalesScreenState();
}

class _DocumentosLegalesScreenState extends State<DocumentosLegalesScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'Pantalla de Inicio',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: GlobalVariables.primaryColor, 
          ),
        ),
      ),
    );
  }
}