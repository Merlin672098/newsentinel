import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../constants/constants.dart';



class PasajeroService {
  Future<void> sendCodeToBackend(String code, String idhijo) async {
    try {
      final response = await http.post(
        Uri.parse('$uri/codigo/codigo-generado'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'codigo': code, 
          'idhijo': idhijo,
        }),
      );

      if (response.statusCode == 200) {
        print('Código asociado exitosamente');
      } else {
        print('Error al asociar código: ${response.reasonPhrase}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }

  Future<void> sendCodeToBackendPadre(String code, String idpadre) async {
    try {
      final response = await http.post(
        Uri.parse('$uri/codigo/agregar'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'codigo': code, // Cambié 'code' a 'codigo' para coincidir con el backend
          'idpadre': idpadre,
        }),
      );

      if (response.statusCode == 200) {
        print('Código asociado exitosamente');
      } else {
        print('Error al asociar código: ${response.reasonPhrase}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }
}