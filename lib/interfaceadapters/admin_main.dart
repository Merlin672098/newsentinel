import 'package:flutter/material.dart';
import 'package:newsentinel/interfaceadapters/provider/user.dart';
import 'package:provider/provider.dart';

import '../../constants/global_variables.dart';


class AdminMain extends StatefulWidget {
  //static const String routeName = '/actual-home3';
  const AdminMain({Key? key}) : super(key: key);

  @override
  State<AdminMain> createState() => _BottomBar3State();
}

class _BottomBar3State extends State<AdminMain> {
  int _page = 0;

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    String selectedUserId = Provider.of<UserProvider>(context, listen: false).user.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PADRE',
            style: TextStyle(color: Color.fromARGB(255, 252, 252, 252), ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 60, 110),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: () {
              //AuthService().signOut(context); 
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: GlobalVariables.appBarGradient,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                updatePage(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Codigo'),
              onTap: () {
                updatePage(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Ubicacion'),
              onTap: () {
                updatePage(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _page,
        children: [
          //Home(),
          //Codigo(),
          //Ubicacion(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: GlobalVariables.meBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home_outlined,
                  color: _page == 0
                      ? GlobalVariables.selectedNavBarColor
                      : GlobalVariables.unselectedNavBarColor),
              onPressed: () => updatePage(0),
            ),
          ],
        ),
      ),
    );
  }
}
