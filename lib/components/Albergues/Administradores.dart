import 'package:app_cotopaxi/components/Usuarios/user_info_screen.dart';
import 'package:flutter/material.dart';
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
        Uri.parse(
            'https://bd45-201-183-161-189.ngrok-free.app/api/usuario/${widget.albergueId}/albergue'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print(response.body);
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
    );
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
                    Icons.home_repair_service,
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
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: administradores.length,
                      itemBuilder: (context, index) {
                        final administrador = administradores[index];
                        return GestureDetector(
                          onTap: () => _showUserOptions(context, administrador),
                          child: Container(
                            width: 250,
                            margin: EdgeInsets.all(8),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${administrador['nombre'].toString()} ${administrador['apellido']}' ??
                                          'Sin nombre',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color.fromRGBO(14, 54, 115, 1),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    InfoRow(
                                      icon: Icons.email,
                                      label: 'Email',
                                      value: administrador['email'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.credit_card,
                                      label: 'Cédula',
                                      value: administrador['cedula'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.phone,
                                      label: 'Teléfono',
                                      value: administrador['telefono'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.person,
                                      label: 'Rol',
                                      value: administrador['rol'] ?? 'N/A',
                                    ),
                                  ],
                                ),
                              ),
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

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic value;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Color.fromRGBO(14, 54, 115, 0.8)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ${value is bool ? (value ? 'Sí' : 'No') : value.toString()}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
