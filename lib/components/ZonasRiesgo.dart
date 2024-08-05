import 'package:app_cotopaxi/components/ZonaRiesgo/zonaRiesgo_edit_screen.dart';
import 'package:app_cotopaxi/components/ZonaRiesgo/zonaRiesgo_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ZonasRiesgo extends StatefulWidget {
  @override
  _ZonasRiesgoState createState() => _ZonasRiesgoState();
}

class _ZonasRiesgoState extends State<ZonasRiesgo> {
  List<dynamic> ZonasRiesgo = [];
  List<dynamic> filteredZonasRiesgo = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchZonasRiesgo();
    searchController.addListener(_filterZonasRiesgo);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchZonasRiesgo();
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filteredZonasRiesgo = ZonasRiesgo;
      }
    });
  }

  void _filterZonasRiesgo() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredZonasRiesgo = ZonasRiesgo.where((zonasRiesgo) {
        return zonasRiesgo['nombre'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showZonaRiesgoOptions(BuildContext context, dynamic zonaRiesgo) {
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
                '${zonaRiesgo['nombre']}',
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
                  _viewZonaRiesgoInfo(context, zonaRiesgo);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.edit, color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Editar información'),
                onTap: () {
                  Navigator.pop(context);
                  _editZonaRiesgoInfo(context, zonaRiesgo);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.delete, color: Color.fromRGBO(255, 0, 0, 1)),
                title: Text('Eliminar Sitio Seguro'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteZonaRiesgo(context, zonaRiesgo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteZonaRiesgo(
      BuildContext context, dynamic zonaRiesgo) async {
    // Capturar el ScaffoldMessenger.of(context) al inicio de la función
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Mostrar un diálogo de confirmación
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text(
              "¿Estás seguro de que quieres eliminar esta zona de riesgo?"),
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
              'http://10.0.2.2:5000/api/domicilios/${zonaRiesgo['_id']}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          await fetchZonasRiesgo();
        } else {
          throw Exception('Failed to delete zona de riesgo: ${response.body}');
        }
      } catch (e) {
        print('Error deleting zona de riesgo: $e');
        // Usar el scaffoldMessenger capturado anteriormente
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error al eliminar la zona de riesgo')),
        );
      }
    }
  }

  Future<void> fetchZonasRiesgo() async {
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
        Uri.parse('http://10.0.2.2:5000/api/domicilios'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          ZonasRiesgo = json.decode(response.body);
          filteredZonasRiesgo = ZonasRiesgo;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load ZonasRiesgo');
      }
    } catch (e) {
      print('Error fetching ZonasRiesgo: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _viewZonaRiesgoInfo(BuildContext context, dynamic zonaRiesgo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZonaRiesgoInfoScreen(zonaRiesgo: zonaRiesgo),
      ),
    );
  }

  void _editZonaRiesgoInfo(BuildContext context, dynamic zonaRiesgo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZonaRiesgoEditScreen(zonaRiesgo: zonaRiesgo),
      ),
    ).then((value) {  
      if (value == true) {
        fetchZonasRiesgo();
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
                    Icons.home_repair_service,
                    color: Color.fromRGBO(14, 54, 115, 1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Zonas en Riesgo",
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
                hintText: 'Buscar sitio zona de riesgo...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    searchController.clear();
                    _filterZonasRiesgo();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (_) => _filterZonasRiesgo(),
            ),
          ),
        SizedBox(height: 5),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredZonasRiesgo.isEmpty
                ? Center(child: Text('No se encontraron Sitios Seguros'))
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredZonasRiesgo.length,
                      itemBuilder: (context, index) {
                        final zonaRiesgo = filteredZonasRiesgo[index];
                        return GestureDetector(
                          onTap: () =>
                              _showZonaRiesgoOptions(context, zonaRiesgo),
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
                                      zonaRiesgo['nombre'] ?? 'Sin nombre',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color.fromRGBO(14, 54, 115, 1),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    InfoRow(
                                      icon: Icons.warning_amber_rounded,
                                      label: 'En Riesgo',
                                      value:
                                          zonaRiesgo['zonaDeRiesgo'] ?? 'N/A',
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
        Icon(icon, size: 20, color: Color.fromRGBO(14, 54, 115, 0.8)),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value is bool ? (value ? 'Sí' : 'No') : value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(14, 54, 115, 1),
          ),
        ),
      ],
    );
  }
}
