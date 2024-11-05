import 'package:flutter/material.dart';
import 'package:newsentinel/constants/global_variables.dart';

class InicioScreen extends StatelessWidget {
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
