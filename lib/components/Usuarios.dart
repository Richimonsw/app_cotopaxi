import 'package:app_cotopaxi/components/Usuarios/user_edit_screen.dart';
import 'package:app_cotopaxi/components/Usuarios/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class Usuarios extends StatefulWidget {
  @override
  _UsuariosState createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {
  final String? baseURL = dotenv.env['BaseURL'];
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
              Divider(
                color: const Color.fromARGB(255, 0, 0, 0),
                thickness: 1,
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(
                  Icons.visibility,
                  color: Color.fromRGBO(14, 54, 115, 1),
                ),
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
    ).then((value) {
      if (value == true) {
        // Si el usuario fue editado exitosamente, actualiza la lista de usuarios
        fetchUsuarios();
      }
    });
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
          Uri.parse(baseURL! + 'usuario/${usuario['_id']}'),
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
        Uri.parse(baseURL! + 'usuario'),
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
                    Icons.person,
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
                  borderRadius: BorderRadius.circular(20),
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
                    height: 290,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredUsuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = filteredUsuarios[index];
                        return GestureDetector(
                          onTap: () => _showUserOptions(context, usuario),
                          child: Container(
                            width: 300,
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Stack(
                              children: [
                                // Fondo con gradiente
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
                                // Contenido
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Foto de perfil y nombre
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
                                                  '${usuario['nombre']} ${usuario['apellido']}' ??
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
                                                    usuario['rol'] ?? 'N/A',
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
                                          value: usuario['telefono'] ?? 'N/A'),
                                      InfoItem(
                                          icon: Icons.home,
                                          value: usuario['albergue']
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
                  )
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
