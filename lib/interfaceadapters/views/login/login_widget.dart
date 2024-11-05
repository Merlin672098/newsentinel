import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:newsentinel/constants/global_variables.dart';
import 'package:newsentinel/interfaceadapters/gateways/login_service.dart';
import 'package:newsentinel/interfaceadapters/provider/user.dart';
import 'package:provider/provider.dart';
import '../../../constants/constants.dart';
import '../../../domain/entities/usuario.dart';
import '../../../main.dart';
import 'forgot_password_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class LoginWidget extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginWidget({
    Key? key,
    required this.onClickedSignUp,
  }) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final LoginService loginService = LoginService();


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) => SingleChildScrollView(
      child: Container(
        width: double.infinity,  // Asegura que el Container ocupe todo el ancho
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: GlobalVariables.primaryColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 1),
              child: Image.asset(
                'assets/logosentinel.png',
                height: 250,
              ),
            ),
            const SizedBox(height: 1),
            const Text(
              'Sentinel',
              style: TextStyle(
                color: GlobalVariables.secondaryColor,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  foregroundColor: GlobalVariables.primaryColor,
                  backgroundColor: GlobalVariables.secondaryColor,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Padding(
              padding:  EdgeInsets.symmetric(horizontal: 30),
              child:  Text(
                'o',
                style: TextStyle(
                  color: GlobalVariables.secondaryColor,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton.icon(
                onPressed: iniciarSesion,
                icon: Image.asset(
                  'assets/Google__G__logo.png',
                  height: 24,
                  width: 24,
                ),
                label: const Text('Iniciar sesión con Google'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(230, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
              ),
              child: const Text(
                '¿Has olvidado tu contraseña?',
                style: TextStyle(
                  color: GlobalVariables.secondaryColor,
                  fontSize: 18,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '¿No tienes cuenta?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: widget.onClickedSignUp,
              child: const Text(
                'Regístrate',
                style: TextStyle(
                  color: GlobalVariables.secondaryColor,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );


  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String uid = user.uid;
        Provider.of<UserProvider>(context, listen: false).setUser(uid);
        //print("UID del usuario autenticado: $uid");
      } else {
        print("No se pudo obtener el UID del usuario.");
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      // Utils.showSnackBar(e.message); // Si Utils.showSnackBar está definido en otra parte
    }

    // Navigator.of(context) not working!
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future<void> signInUserGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // El usuario canceló la operación
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

      // Crear una instancia de tu modelo de usuario
      Usuario user = Usuario(
        id: uid,
        name: displayName ?? '',
        email: email ?? '',
        password: '', // La autenticación de Google no requiere una contraseña
        type: 'estudiante', // Rol añadido
        token: '', // Si tienes un token lo puedes agregar
        modoOscuro: false, 
        verificacion: firebaseUser.emailVerified, // Verificación de correo
      );

      // Actualizar el estado del UserProvider
      Provider.of<UserProvider>(context, listen: false).setUserFromModel(user);

      // Obtener el playerId de OneSignal
      final deviceState = await OneSignal.User.pushSubscription.id;
      String playerId = deviceState ?? '';
      print('Player ID: $playerId');

      // Inserta la información en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'role': 'estudiante', 
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
          'role': 'estudiante',
          'createdAt': DateTime.now().toIso8601String(), 
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(uid);
      print(displayName);
      print(email);
      print(photoURL);
      print(playerId);
      print(res.body);
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

  void iniciarSesion() {
    loginService.signInUserGoogle();
  } 
}
