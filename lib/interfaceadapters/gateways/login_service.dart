import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newsentinel/constants/constants.dart';
import 'package:newsentinel/constants/utils2.dart';
import 'package:newsentinel/interfaceadapters/provider/user.dart';
import 'package:newsentinel/main.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  Future<void> signInUserGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        String uid = firebaseUser.uid;
        String? email = firebaseUser.email;
        String? displayName = firebaseUser.displayName;
        String? photoURL = firebaseUser.photoURL;


        final deviceState = await OneSignal.User.pushSubscription.id;
        String playerId = deviceState ?? '';
        print('Player ID: $playerId');

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'displayName': displayName,
          'photoURL': photoURL,
          'role': 'conductor', 
          'createdAt': FieldValue.serverTimestamp(), 
        });

        http.Response res = await http.post(
          Uri.parse('$uri/api/signinGoogle'),
          body: jsonEncode({
            'uid': uid,
            'displayName': displayName,
            'email': email,
            'password': '', 
            'playerId': playerId,
            'photoURL': photoURL,
            'role': 'conductor',
          // 'modoOscuro': false, // Valor por defecto
          // 'verificacion': firebaseUser.emailVerified, 
            'createdAt': DateTime.now().toIso8601String(), 
          }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        /*httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
         // SharedPreferences prefs = await SharedPreferences.getInstance();
        //  Provider.of<UserProvider>(context, listen: false).setUser(res.body);

          String userId = jsonDecode(res.body)['_id'];
          UserProvider().setUserId(userId);

          print(userId);
        },
      );*/
          String userId = jsonDecode(res.body)['_id'];
          //print(userId);
          String? photoUrl = firebaseUser.photoURL;
          String? name = firebaseUser.displayName;
          //print(photoUrl);
          UserProvider().setUserId(userId);
          UserProvider().setPhotoURL(photoUrl!);
          UserProvider().setUserName(name!);
        if (res.statusCode == 200) {
          print("Usuario autenticado e insertado correctamente.");
        } else {
          print("Error en el servidor: ${res.body}");
        }
      } else {
        print("No se pudo obtener el UID del usuario.");
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
  // Cerrar sesión
Future<void> signOut() async {
  try {
    // Cerrar sesión de Google si está autenticado con Google
    GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    // Cerrar sesión en Firebase
    await FirebaseAuth.instance.signOut();

    // Opcional: Limpiar otros datos locales si es necesario, por ejemplo:
    // await SharedPreferences.getInstance().clear();

    print('User signed out successfully');
  } catch (e) {
    print('Sign out error: $e');
  }
}
  void getUserData(
    BuildContext context,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      print(token);

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
        );

        var userData = jsonDecode(userRes.body);

        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userData);

        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar2(context, e.toString());
    }
  }

}
