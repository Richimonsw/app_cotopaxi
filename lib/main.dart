import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_cotopaxi/paginas/login.dart';
import 'package:app_cotopaxi/paginas/navbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SessionHandler(),
    );
  }
}

class SessionHandler extends StatefulWidget {
  @override
  _SessionHandlerState createState() => _SessionHandlerState();
}

class _SessionHandlerState extends State<SessionHandler> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.containsKey('nombres');

  // Obtener la ruta actual
  String currentRoute = ModalRoute.of(context)!.settings.name!;


  // Verificar si la ruta actual es la del mapa
  bool isMapScreen = currentRoute == '/mapa'; // Reemplaza '/mapa' con la ruta real del mapa

  setState(() {
    this.isLoggedIn = isLoggedIn;
  });

  if (isLoggedIn && isMapScreen) {
    // Si el usuario está logueado y está en la pantalla del mapa, cerrar la aplicación
    Navigator.of(context).pop(true);
  }
}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Controla el comportamiento al presionar el botón de retroceso
        // Si el usuario ha iniciado sesión, cierra la aplicación
        if (isLoggedIn) {
          return true; // Cierra la aplicación
        } else {
          return false; // Permite el regreso al inicio de sesión
        }
      },
      child: isLoggedIn ? MyHomePage() : LoginPage(),
    );
  }
}
