import 'package:app_cotopaxi/components/Usuarios/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Administradores extends StatefulWidget {
  final String albergueId;

  Administradores({required this.albergueId});

  @override
  _AdministradoresState createState() => _AdministradoresState();
}

class _AdministradoresState extends State<Administradores> {
  final String? baseURL = dotenv.env['BaseURL'];
  List<dynamic> administradores = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchAdministradores();
  }

  Future<void> fetchAdministradores() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }
      final response = await http.get(
        Uri.parse(baseURL! + 'usuario/${widget.albergueId}/albergue'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          administradores = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load administradores');
      }
    } catch (e) {
      setState(() {
        error = 'Error al obtener administradores';
        isLoading = false;
      });
    }
  }

  void _showUserOptions(BuildContext context, dynamic administrador) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${administrador['nombre'].toString()} ${administrador['apellido'].toString()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(14, 54, 115, 1),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.visibility,
                    color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Ver información'),
                onTap: () {
                  Navigator.pop(context);
                  _viewUserInfo(context, administrador);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewUserInfo(BuildContext context, dynamic administrador) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(usuario: administrador),
      ),
    ).then((value) {
      if (value == true) {
        // Si el usuario fue editado exitosamente, actualiza la lista de usuarios
        fetchAdministradores();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Color.fromRGBO(14, 54, 115, 1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Administradores",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(14, 54, 115, 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : administradores.isEmpty
                ? Center(child: Text("No hay administradores disponibles"))
                : SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: administradores.length,
                      itemBuilder: (context, index) {
                        final administrador = administradores[index];
                        return GestureDetector(
                          onTap: () => _showUserOptions(context, administrador),
                          child: Container(
                            width: 300,
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromRGBO(14, 54, 115, 1),
                                        Color.fromRGBO(54, 94, 155, 1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 3),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                    'assets/icon/setting.png'),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${administrador['nombre']} ${administrador['apellido']}' ??
                                                      'Sin nombre',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Text(
                                                    administrador['rol'] ?? 'N/A',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 24),
                                      // Información de contacto
                                      // InfoItem(
                                      //     icon: Icons.email,
                                      //     value: usuario['email'] ?? 'N/A'),
                                      // InfoItem(
                                      //     icon: Icons.credit_card,
                                      //     value: usuario['cedula'] ?? 'N/A'),
                                      InfoItem(
                                          icon: Icons.phone,
                                          value: administrador['telefono'] ?? 'N/A'),
                                      InfoItem(
                                          icon: Icons.home,
                                          value: administrador['albergue']
                                                  ['nombre'] ??
                                              'N/A'),
                                    ],
                                  ),
                                ),
                                // Decoración geométrica
                                Positioned(
                                  right: -20,
                                  bottom: -20,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 40,
                                  top: -30,
                                  child: Transform.rotate(
                                    angle: 0.3,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const InfoItem({Key? key, required this.icon, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white.withOpacity(0.7)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
