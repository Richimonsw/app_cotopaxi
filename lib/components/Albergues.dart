import 'package:app_cotopaxi/components/Albergues/albergue_edit_screen.dart';
import 'package:app_cotopaxi/components/Albergues/albergue_info_screen.dart';
import 'package:app_cotopaxi/components/Albergues/contenido_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Albergues extends StatefulWidget {
  @override
  _AlberguesState createState() => _AlberguesState();
}

class _AlberguesState extends State<Albergues> {
  final String? baseURL = dotenv.env['BaseURL'];
  List<dynamic> albergues = [];
  List<dynamic> filteredAlbergues = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAlbergues();
    searchController.addListener(_filterAlbergues);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filteredAlbergues = albergues;
      }
    });
  }

  void _filterAlbergues() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredAlbergues = albergues.where((albergue) {
        return albergue['nombre'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAlbergueOptions(BuildContext context, dynamic albergue) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${albergue['nombre']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(14, 54, 115, 1),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading:
                    Icon(Icons.login, color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Entrar al albergue'),
                onTap: () {
                  Navigator.pop(context);
                  _viewAlbergueContent(context, albergue);
                },
              ),
              ListTile(
                leading: Icon(Icons.visibility,
                    color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Ver información'),
                onTap: () {
                  Navigator.pop(context);
                  _viewAlbergueInfo(context, albergue);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.edit, color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Editar información'),
                onTap: () {
                  Navigator.pop(context);
                  _editAlbergueInfo(context, albergue);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.delete, color: Color.fromRGBO(255, 0, 0, 1)),
                title: Text('Eliminar Albergue'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAlbergue(context, albergue);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewAlbergueContent(BuildContext context, dynamic albergue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContenidoScreen(albergue: albergue),
      ),
    );
  }

  void _viewAlbergueInfo(BuildContext context, dynamic albergue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbergueInfoScreen(albergue: albergue),
      ),
    );
  }

  void _editAlbergueInfo(BuildContext context, dynamic albergue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbergueEditScreen(albergue: albergue),
      ),
    ).then((value) {
      if (value == true) {
        // Si el usuario fue editado exitosamente, actualiza la lista de usuarios
        fetchAlbergues();
      }
    });
  }

  Future<void> _deleteAlbergue(BuildContext context, dynamic albergue) async {
    // Capturar el ScaffoldMessenger.of(context) al inicio de la función
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Mostrar un diálogo de confirmación
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que quieres eliminar este albergue?"),
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
          Uri.parse(baseURL! + 'albergue/${albergue['_id']}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          await fetchAlbergues();
        } else {
          throw Exception('Failed to delete albergue: ${response.body}');
        }
      } catch (e) {
        print('Error deleting albergue: $e');
        // Usar el scaffoldMessenger capturado anteriormente
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error al eliminar el albergue')),
        );
      }
    }
  }

  Future<void> fetchAlbergues() async {
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
        Uri.parse(baseURL! + 'albergue'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print(response);

      if (response.statusCode == 200) {
        setState(() {
          albergues = json.decode(response.body);
          filteredAlbergues = albergues;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load albergues');
      }
    } catch (e) {
      print('Error fetching albergues: $e');
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
                    Icons.home_work,
                    color: Color.fromRGBO(14, 54, 115, 1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Albergues",
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
                hintText: 'Buscar albergue...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    searchController.clear();
                    _filterAlbergues();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (_) => _filterAlbergues(),
            ),
          ),
        SizedBox(height: 5),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredAlbergues.isEmpty
                ? Center(child: Text('No se encontraron albergues'))
                : SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredAlbergues.length,
                      itemBuilder: (context, index) {
                        final albergue = filteredAlbergues[index];
                        return GestureDetector(
                          onTap: () => _showAlbergueOptions(context, albergue),
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
                                        Color(0xFF2E8B57), // Verde mar oscuro
                                        Color(0xFF3CB371), // Verde mar medio
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
                                      Row(
                                        children: [
                                          Icon(Icons.home_work,
                                              color: Colors.white, size: 32),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              albergue['nombre'] ??
                                                  'Sin nombre',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: Colors.white70, size: 18),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Coordenadas: ${albergue['cordenadas_x']}, ${albergue['cordenadas_y']}',
                                              style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InfoColumn(
                                            icon: Icons.people,
                                            label: 'Ciudadanos',
                                            value: '${albergue['ciudadanosCount'] ?? 0}/${albergue['capacidadCiudadanos']}',
                              
                                          ),
                                          InfoColumn(
                                            icon: Icons.person,
                                            label: 'Usuarios',
                                            value:
                                                '${albergue['usuariosCount'] ?? 0}/${albergue['capacidadUsuarios']}',
                                          ),
                                          InfoColumn(
                                            icon: Icons.store,
                                            label: 'Bodegas',
                                            value:
                                                '${albergue['bodegasCount'] ?? 0}/${albergue['capacidadBodegas']}',
                                          ),
                                        ],
                                      ),
                                      
                                    ],
                                  ),
                                ),
                                // Elemento decorativo
                                Positioned(
                                  right: -30,
                                  top: -30,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      shape: BoxShape.circle,
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

class InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoColumn(
      {Key? key, required this.icon, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ],
    );
  }
}
