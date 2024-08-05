import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final String? baseURL = dotenv.env['BaseURL'];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText =
      true; // Variable para controlar la visibilidad de la contraseña

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 207, 255, 245),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 80),
                Center(
                  child: ClipOval(
                    child: Image.network(
                      'https://res.cloudinary.com/dlyytqayv/image/upload/v1708699571/Cotopaxi/nomjfagmofg2n87kdjyj.jpg',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Nombre',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText:
                        _obscureText, // Utiliza el valor de _obscureText para mostrar u ocultar la contraseña
                    decoration: InputDecoration(
                      hintText: 'Cédula/Contraseña',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureText =
                                !_obscureText; // Cambia el estado para mostrar u ocultar la contraseña
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 100),
                  child: ElevatedButton(
                    onPressed: () {
                      _login(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '¿No tienes una cuenta?',
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: _launchUrl,
                        child: Text(
                          'Regístrate',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final Uri _url = Uri.parse('https://formulario-cotopaxi.onrender.com');
  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _showNoInternetSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parece que no tienes conexión a Internet.'),
      ),
    );
  }

  void _login(BuildContext context) async {
    final String name = _nameController.text.trim();
    final String password = _passwordController.text.trim();
    final String apiUrl = baseURL! + 'ciudadano/login';
    var body = {
      'nombre': name,
      'cedula': password,
    };

    final Map<String, String> _headers = {"content-type": "application/json"};
    var body2 = jsonEncode(body);

    final String apiUrlAdmin = baseURL! + 'usuario/login';
    var bodyAdmin = {
      'nombre': name,
      'password': password,
    };
    final Map<String, String> _headersAdmin = {
      "content-type": "application/json"
    };
    var body2Admin = jsonEncode(bodyAdmin);

    // Verificar la conexión a internet
    bool isConnected = await checkInternetConnection();

    if (isConnected) {
      // Si hay conexión, realizar la solicitud al servidor
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: _headers,
        body: body2,
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> content = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          prefs.setString("nombres", content["ciudadano"]["nombre"] ?? "");
          prefs.setString("apellidos", content["ciudadano"]["apellido"] ?? "");
          // Maneja el caso en que albergue es null
          prefs.setString("albergue",
              content["ciudadano"]["albergue"]?["nombre"] ?? "Sin asignar");
          prefs.setString("cedula", content["ciudadano"]["cedula"] ?? "");
          // prefs.setString(
          //     "profileImageUrl",
          //     content["persona"]
          //         ["imgPerfil"]); // Guardar URL de la imagen de perfil
        });

        // Guardar la imagen del qrURL en la caché
        String qrUrl = content["ciudadano"]["qrURL"] ?? "";
        if (qrUrl.isNotEmpty) {
          String qrImagePath = await downloadAndSaveImage(qrUrl);
          prefs.setString("qrImagePath", qrImagePath);
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        final responseAdmin = await http.post(Uri.parse(apiUrlAdmin),
            headers: _headersAdmin, body: body2Admin);
        if (responseAdmin.statusCode == 200) {
          Map<String, dynamic> contentAdmin = json.decode(responseAdmin.body);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          setState(() {
            prefs.setString("nombres", contentAdmin["usuario"]["nombre"]);
            prefs.setString("apellidos", contentAdmin["usuario"]["apellido"]);
            prefs.setString(
                "albergue",
                contentAdmin["usuario"]["albergue"]?["nombre"] ??
                    "Sin asignar");
            prefs.setString("cedula", contentAdmin["usuario"]["cedula"]);
            prefs.setString("rol", contentAdmin["usuario"]["rol"]);
            prefs.setString("token", contentAdmin["token"]);
          });

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Usuario/Contraseña incorrecto'),
                content: Text(
                    'El usuario o contraseña que ingresaste son incorrrectos. Vuelve a ingresar correctamente tus datos.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Aceptar'),
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      _showNoInternetSnackBar(context);
    }
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }

  Future<String> downloadAndSaveImage(String imageUrl) async {
    // Obtener el directorio de caché
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String fileName = imageUrl.split('/').last;
    String filePath = '$tempPath/$fileName';

    // Descargar la imagen desde la URL
    http.Response response = await http.get(Uri.parse(imageUrl));

    // Guardar la imagen en el directorio de caché
    File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }
}
