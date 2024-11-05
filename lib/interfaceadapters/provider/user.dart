import 'package:flutter/material.dart';
import 'package:newsentinel/domain/entities/usuario.dart';

class UserProvider extends ChangeNotifier {
  // Parte para gestionar el usuario
  Usuario _user = Usuario(
    id: '',
    name: '',
    email: '',
    password: '',
    type: '', 
    token: '',
    modoOscuro: false,
    verificacion: false,
  );

  Usuario get user => _user;

  void setUser(String user) {
    _user = Usuario.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(Usuario user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = Usuario(
      id: '',
      name: '',
      email: '',
      password: '',
      type: '', 
      token: '',
      modoOscuro: false,
      verificacion: false,
    );
    notifyListeners();
  }


  static final UserProvider _instance = UserProvider._internal();

  String _userId = '';
  String _photoUrl = '';
  String _name = '';


  UserProvider._internal();

  factory UserProvider() {
    return _instance;
  }
    get instance => this;


  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void setPhotoURL(String photoUrl){
    _photoUrl = photoUrl;
    notifyListeners();
  }

  void setUserName(String name) {
    _name = name;
    notifyListeners();
  }

  String getUserId() {
    //print('Llamando a getUserId() en UserProvider');
    print('ID del usuario: $_userId');
    return _userId;
  }

  String getUserName() {
    return _name;
  }

  String getUserEmail() {
    return _user.email;
  }

  String getUserType() {
    return _user.type;
  }

  String getUserToken() {
    return _user.token;
  }

  bool getUserModoOscuro() {
    return _user.modoOscuro;
  }

  bool getUserVerificacion() {
    return _user.verificacion;
  }

  String getPhotoUrl(){
    return _photoUrl;
  }

}
