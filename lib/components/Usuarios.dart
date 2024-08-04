import 'package:app_cotopaxi/components/Usuarios/user_edit_screen.dart';
import 'package:app_cotopaxi/components/Usuarios/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class Usuarios extends StatefulWidget {
  @override
  _UsuariosState createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {
  List<dynamic> usuarios = [];
  List<dynamic> filteredUsuarios = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
    searchController.addListener(_filterUsuarios);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchUsuarios();
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filteredUsuarios = usuarios;
      }
    });
  }

  void _filterUsuarios() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsuarios = usuarios.where((usuario) {
        return usuario['nombre'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showUserOptions(BuildContext context, dynamic usuario) {
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
                '${usuario['nombre']} ${usuario['apellido']}',
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
                  _viewUserInfo(context, usuario);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.edit, color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Editar información'),
                onTap: () {
                  Navigator.pop(context);
                  _editUserInfo(context, usuario);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.delete, color: Color.fromRGBO(255, 0, 0, 1)),
                title: Text('Eliminar Usuario'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteUser(context, usuario);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewUserInfo(BuildContext context, dynamic usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(usuario: usuario),
      ),
    );
  }

  void _editUserInfo(BuildContext context, dynamic usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserEditScreen(usuario: usuario),
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context, dynamic usuario) async {
    // Capturar el ScaffoldMessenger.of(context) al inicio de la función
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Mostrar un diálogo de confirmación
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que quieres eliminar este usuario?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text("Eliminar"),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        if (token == null) {
          throw Exception('No se encontró el token de autenticación');
        }

        final response = await http.delete(
          Uri.parse(
              'https://bd45-201-183-161-189.ngrok-free.app/api/usuario/${usuario['_id']}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          await fetchUsuarios();
        } else {
          throw Exception('Failed to delete user: ${response.body}');
        }
      } catch (e) {
        print('Error deleting user: $e');
        // Usar el scaffoldMessenger capturado anteriormente
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error al eliminar el usuario')),
        );
      }
    }
  }

  Future<void> fetchUsuarios() async {
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
        Uri.parse('https://bd45-201-183-161-189.ngrok-free.app/api/usuario'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          usuarios = json.decode(response.body);
          filteredUsuarios = usuarios;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load usuarios');
      }
    } catch (e) {
      print('Error fetching usuarios: $e');
      setState(() {
        isLoading = false;
      });
    }
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
                    "Usuarios",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(14, 54, 115, 1),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(isSearching ? Icons.close : Icons.search),
                onPressed: _toggleSearch,
                color: Color.fromRGBO(14, 54, 115, 1),
              ),
            ],
          ),
        ),
        if (isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    searchController.clear();
                    _filterUsuarios();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (_) => _filterUsuarios(),
            ),
          ),
        SizedBox(height: 5),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredUsuarios.isEmpty
                ? Center(child: Text('No se encontraron usuarios'))
                : SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredUsuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = filteredUsuarios[index];
                        return GestureDetector(
                          onTap: () => _showUserOptions(context, usuario),
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
                                      '${usuario['nombre']} ${usuario['apellido']}' ??
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
                                      value: usuario['email'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.credit_card,
                                      label: 'Cédula',
                                      value: usuario['cedula'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.phone,
                                      label: 'Teléfono',
                                      value: usuario['telefono'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.person,
                                      label: 'Rol',
                                      value: usuario['rol'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.home,
                                      label: 'Albergue',
                                      value: usuario['albergue']['nombre'] ??
                                          'N/A',
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
