import 'package:flutter/material.dart';
import 'package:app_cotopaxi/paginas/mapa.dart';
import 'package:app_cotopaxi/paginas/perfil.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ProfilePage(),
    MapScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.blue, boxShadow: [
          new BoxShadow(
            color: Color.fromARGB(255, 129, 129, 129),
            blurRadius: 10.0,
            spreadRadius: 5.0,
            offset: new Offset(0.0, 3.0),
          ),
        ] // Cambia el color de fondo a verde aquí
            ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors
              .blue, // Cambia el color de los íconos seleccionados a verde
          unselectedItemColor: Colors
              .black, // Cambia el color de los íconos no seleccionados a blanco
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.location_on,
                color: Color.fromARGB(
                    255, 243, 33, 33), // Cambia el color del icono aquí
              ),
              label: 'Mapa',
              // Si también deseas cambiar el color del texto, puedes utilizar el siguiente enfoque
              // label: Text(
              //   'Mapa',
              //   style: TextStyle(color: Colors.blue), // Cambia el color del texto aquí
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
