import 'package:app_cotopaxi/components/SitioSeguros/sitioSeguro_edit_screen.dart';
import 'package:app_cotopaxi/components/SitioSeguros/sitioSeguro_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SitiosSeguros extends StatefulWidget {
  @override
  _SitiosSegurosState createState() => _SitiosSegurosState();
}

class _SitiosSegurosState extends State<SitiosSeguros> {
  List<dynamic> SitiosSeguros = [];
  List<dynamic> filteredSitiosSeguros = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSitiosSeguros();
    searchController.addListener(_filterSitiosSeguros);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchSitiosSeguros();
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filteredSitiosSeguros = SitiosSeguros;
      }
    });
  }

  void _filterSitiosSeguros() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredSitiosSeguros = SitiosSeguros.where((sitiosSeguro) {
        return sitiosSeguro['nombre'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showSitioSeguroOptions(BuildContext context, dynamic sitioSeguro) {
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
                '${sitioSeguro['nombre']}',
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
                  _viewSitioSeguroInfo(context, sitioSeguro);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.edit, color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Editar información'),
                onTap: () {
                  Navigator.pop(context);
                  _editSitioSeguroInfo(context, sitioSeguro);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.delete, color: Color.fromRGBO(255, 0, 0, 1)),
                title: Text('Eliminar Sitio Seguro'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteSitioSeguro(context, sitioSeguro);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteSitioSeguro(
      BuildContext context, dynamic sitioSeguro) async {
    // Capturar el ScaffoldMessenger.of(context) al inicio de la función
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Mostrar un diálogo de confirmación
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content:
              Text("¿Estás seguro de que quieres eliminar este sitio seguro?"),
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
              'https://bd45-201-183-161-189.ngrok-free.app/api/sitioSeguro/${sitioSeguro['_id']}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          await fetchSitiosSeguros();
        } else {
          throw Exception('Failed to delete sitio seguro: ${response.body}');
        }
      } catch (e) {
        print('Error deleting sitio seguro: $e');
        // Usar el scaffoldMessenger capturado anteriormente
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error al eliminar el sitio seguro')),
        );
      }
    }
  }

  Future<void> fetchSitiosSeguros() async {
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
            'https://bd45-201-183-161-189.ngrok-free.app/api/sitioSeguro'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          SitiosSeguros = json.decode(response.body);
          filteredSitiosSeguros = SitiosSeguros;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load SitiosSeguros');
      }
    } catch (e) {
      print('Error fetching SitiosSeguros: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _viewSitioSeguroInfo(BuildContext context, dynamic sitioSeguro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SitioSeguroInfoScreen(sitioSeguro: sitioSeguro),
      ),
    );
  }

  void _editSitioSeguroInfo(BuildContext context, dynamic sitioSeguro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SitioSeguroEditScreen(sitioSeguro: sitioSeguro),
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
                    Icons.security,
                    color: Color.fromRGBO(14, 54, 115, 1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Sitios Seguros",
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
                hintText: 'Buscar sitio seguro...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    searchController.clear();
                    _filterSitiosSeguros();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (_) => _filterSitiosSeguros(),
            ),
          ),
        SizedBox(height: 5),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredSitiosSeguros.isEmpty
                ? Center(child: Text('No se encontraron Sitios Seguros'))
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredSitiosSeguros.length,
                      itemBuilder: (context, index) {
                        final sitioSeguro = filteredSitiosSeguros[index];
                        return GestureDetector(
                          onTap: () =>
                              _showSitioSeguroOptions(context, sitioSeguro),
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
                                      sitioSeguro['nombre'] ?? 'Sin nombre',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color.fromRGBO(14, 54, 115, 1),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    InfoRow(
                                      icon: Icons.location_on,
                                      label: 'Cordenadas X',
                                      value:
                                          sitioSeguro['cordenadas_x'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.location_on,
                                      label: 'Cordenadas Y',
                                      value:
                                          sitioSeguro['cordenadas_y'] ?? 'N/A',
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
  final int value;

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
          '$value',
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