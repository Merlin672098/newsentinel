import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:newsentinel/domain/provider/sanctuary.dart';
import 'package:newsentinel/interfaceadapters/admin_main.dart';
import 'package:newsentinel/interfaceadapters/provider/user.dart';
import 'dart:convert';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../../constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  void signIn({
    required BuildContext context,
    //required String email,
  }) async {
    try {
      GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user != null) {
        GoogleSignInAuthentication auth = await user.authentication;
        String email = user.email;
        String? usuarionombre = user.displayName;
        //print(usuarionombre);
        //print('ID del Usuario: ${user.id}');
        //print('Nombre del Usuario: ${user.displayName}');

        await _verifyEmailWithBackend(context, email, usuarionombre!);
      } else {
        print('Google Sign-In failed or was cancelled');
      }
    } catch (error) {
      print('Error during Google sign-in: $error');
    }
  }

  Future<void> _verifyEmailWithBackend(
      BuildContext context, String email, String usuarionombre) async {
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

      final deviceState = await OneSignal.User.pushSubscription.id;
      String playerId = deviceState ?? '';
      print('Player ID: $playerId');

      final response = await http.post(
        Uri.parse('$uri/api/signinGoogle'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'usuarionombre': usuarionombre,
          'playerId': playerId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Logged in successfully: $data');

        print('Type of idusuario: ${data['idusuario'].runtimeType}');

        Provider.of<UserProvider>(context, listen: false)
            .setUser(response.body);

        String userId = data['idusuario'].toString();
        UserIdManager.setUserId(userId);
        //UserProvider().setUserId(userId);
        print('User ID: $userId');

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => AdminMain()),
        );
      } else {
        print('Error verifying email: ${response.body}');
      }
    } catch (error) {
      print('Error during email verification: $error');
    }
  }
void signOut(BuildContext context) async {
  try {
    GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }

    await FirebaseAuth.instance.signOut();


    print('User signed out successfully');
  } catch (e) {
    print('Sign out error: $e');
  }
}


  // Cerrar sesión
  /*void signOut2(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('x-auth-token');
      Provider.of<UserProvider>(context, listen: false).clearUser();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/auth-screen',
        (route) => false,
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }*/
}
