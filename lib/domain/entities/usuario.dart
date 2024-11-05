import 'dart:convert';

class Usuario {
  final String id;
  final String name;
  final String email;
  final String password;
  final String type;
  final String token;
  final bool modoOscuro;
  final bool verificacion;
  final String photoUrl;

  Usuario({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.type,
    required this.token,
    this.modoOscuro = false,
    this.verificacion = false,
    this.photoUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'type': type,
      'token': token,
      'modoOscuro': modoOscuro,
      'verificacion': verificacion,
      'photoUrl': photoUrl,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      type: map['type'] ?? '',
      token: map['token'] ?? '',
      modoOscuro: map['modoOscuro'] ?? false,
      verificacion: map['verificacion'] ?? false,
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Usuario.fromJson(String source) =>
      Usuario.fromMap(json.decode(source));

  Usuario copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? type,
    String? token,
    bool? modoOscuro,
    bool? verificacion,
    String? photoUrl,
  }) {
    return Usuario(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      type: type ?? this.type,
      token: token ?? this.token,
      modoOscuro: modoOscuro ?? this.modoOscuro,
      verificacion: verificacion ?? this.verificacion,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
