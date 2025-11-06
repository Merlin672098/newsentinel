import 'package:flutter/material.dart';
import 'package:newsentinel/interfaceadapters/gateways/login_service.dart';
import 'package:newsentinel/interfaceadapters/provider/user.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/QRScreen.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/amigos_screen.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/dispositivo_screen.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/documentos_legales.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/inicio.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/mapa_viaje.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/perfil_screen.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/ubicacion.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/vehiculos_screen.dart';
import 'package:newsentinel/interfaceadapters/views/conductor/viajes_screen.dart';
import '../../constants/global_variables.dart';

class ConductorMain extends StatefulWidget {
  const ConductorMain({Key? key}) : super(key: key);

  @override
  State<ConductorMain> createState() => _ConductorMainState();
}

class _ConductorMainState extends State<ConductorMain> {
  int _page = 0;
  final LoginService loginService = LoginService();
  //String photoUrl = UserProvider().getPhotoUrl();
  String photoUrl =
      'https://lh3.googleusercontent.com/a/ACg8ocKPeTQB8dOXMx7hM9yc0-kcLaM0QnkwCmChwB1Ww8Bt_EhRdzf2=s96-c';
  //String nombre_user = UserProvider().getUserName();
  String nombre_user = 'Merlin';
  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final userCartLen = context.watch<UserProvider>().user.cart.length;
    //String selectedUserId = Provider.of<UserProvider>(context, listen: false).user.type;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalVariables.secondaryColor,

        title: const Text(
          'Sentinel',
          style: TextStyle(
              color: GlobalVariables.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        //empieza el menu
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: GlobalVariables.primaryColor,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: GlobalVariables.primaryColor,
            ),
            onPressed: () {
              signOut();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: GlobalVariables.secondaryColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: GlobalVariables.primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(photoUrl),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      nombre_user,
                      style: const TextStyle(
                        color: GlobalVariables.secondaryColor,
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      'Conductor',
                      style: TextStyle(
                        color: GlobalVariables.secondaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home,
                    color: GlobalVariables.primaryColor),
                title: const Text(
                  'Inicio',
                  style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  updatePage(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person,
                    color: GlobalVariables.primaryColor),
                title: const Text(
                  'Perfil',
                  style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  updatePage(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people,
                    color: GlobalVariables.primaryColor),
                title: const Text(
                  'Amigos',
                  style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  updatePage(2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.travel_explore,
                    color: GlobalVariables.primaryColor),
                title: const Text(
                  'Viajes',
                  style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  updatePage(3);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.car_rental,
                    color: GlobalVariables.primaryColor),
                title: const Text(
                  'Vehiculos',
                  style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  updatePage(4);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dashboard,
                    color: GlobalVariables.primaryColor),
                title: const Text(
                  'Documentos Legales?',
                  style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  updatePage(5);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment,
                    color: GlobalVariables.primaryColor),
                title: const Text(
                  'Suscripciones',
                  style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  updatePage(5);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment,
                    color: GlobalVariables.primaryColor),
                title: const Text(
                  'Dispositivozzz',
                  style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  updatePage(6);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment,
                    color: GlobalVariables.primaryColor),
                title: const Text(
                  'Dispositivozzz',
                  style: TextStyle(
                    color: GlobalVariables.primaryColor,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  updatePage(6);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _page,
        children: [
          // Pantalla de Inicio
          MapaViaje(), // updatePage(0)

          // Pantalla de Perfil
          PerfilScreen(), // updatePage(1)
          AmigosScreen(),
          // Pantalla de Ubicación
          // UbicacionScreen(), // updatePage(2)

          // Pantalla de Viajes
          ViajesScreen(), // updatePage(3)

          // Pantalla de Vehículos
          VehiculosScreen(), // updatePage(5)

          // Pantalla de Conductores
          //ConductoresScreen(), // updatePage(6)

          // Pantalla de Estudiantes
           // updatePage(7)

          // Pantalla de Documentos Legales
          DocumentosLegalesScreen(), // updatePage(8)
          //DispositivosScreen(),
          //Pantalla de dispositivos
         // QrScannerTab(),
          Sepuedebanda(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: GlobalVariables.secondaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home_outlined,
                  color: _page == 0
                      ? GlobalVariables.primaryColor
                      : GlobalVariables.primaryColor),
              onPressed: () => updatePage(0),
            ),
            IconButton(
              icon: Icon(Icons.person_outline_outlined,
                  color: _page == 1
                      ? GlobalVariables.primaryColor
                      : GlobalVariables.primaryColor),
              onPressed: () => updatePage(1),
            ),
            IconButton(
              icon: Icon(Icons.people_outline,
                  color: _page == 1
                      ? GlobalVariables.primaryColor
                      : GlobalVariables.primaryColor),
              onPressed: () => updatePage(2),
            ),
            IconButton(
              icon: Icon(Icons.travel_explore_outlined,
                  color: _page == 1
                      ? GlobalVariables.primaryColor
                      : GlobalVariables.primaryColor),
              onPressed: () => updatePage(3),
            ),
            //   ...

  /*            badges.Badge(
              //badgeContent: Text(userCartLen.toString()),
              child: IconButton(
                icon: Icon(Icons.shopping_cart_outlined,
                    color: _page == 2
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.unselectedNavBarColor),
                onPressed: () => updatePage(2),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  void signOut() {
    loginService.signOut();
  }
}
