import 'dart:convert';

class Ubicacion {
  final String id;
  final String name;
  final String linea;
  final double latitude;
  final double longitude;
  final String id_usuario;

  Ubicacion({
    required this.id,
    required this.name,
    required this.linea,
    required this.latitude,
    required this.longitude,
    required this.id_usuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'linea': linea,
      'latitude': latitude,
      'longitude': longitude,
      'id_usuario': id_usuario,
    };
  }

  factory Ubicacion.fromMap(Map<String, dynamic> map) {
    return Ubicacion(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      linea: map['linea'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      id_usuario: map['id_usuario'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Ubicacion.fromJson(String source) =>
      Ubicacion.fromMap(json.decode(source));

  Ubicacion copyWith({
    String? id,
    String? name,
    String? linea,
    double? latitude,
    double? longitude,
    String? id_usuario,
  }) {
    return Ubicacion(
      id: id ?? this.id,
      name: name ?? this.name,
      linea: linea ?? this.linea,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      id_usuario: id_usuario ?? this.id_usuario,
    );
  }
}
