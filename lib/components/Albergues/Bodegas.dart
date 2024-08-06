import 'package:app_cotopaxi/components/Bodegas/bodega_edit_screen.dart';
import 'package:app_cotopaxi/components/Bodegas/bodega_info_screen.dart';
import 'package:app_cotopaxi/components/Bodegas/contenidoBodega_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bodegas extends StatefulWidget {
  final String albergueId;

  Bodegas({required this.albergueId});

  @override
  _BodegasState createState() => _BodegasState();
}

class _BodegasState extends State<Bodegas> {
  final String? baseURL = dotenv.env['BaseURL'];
  List<dynamic> bodegas = [];
  List<dynamic> filteredBodegas = [];
  bool isLoading = true;
  bool isSearching = false;
  String? error;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBodegas();
    searchController.addListener(_filterBodegas);
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
        filteredBodegas = bodegas;
      }
    });
  }

  void _filterBodegas() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredBodegas = bodegas.where((bodega) {
        return bodega['nombre'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> fetchBodegas() async {
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
        Uri.parse(baseURL! + 'bodega/${widget.albergueId}/bodegas'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bodegas = data['data'];
          filteredBodegas = bodegas;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load bodegas');
      }
    } catch (e) {
      setState(() {
        error = 'Error al obtener bodegas';
        isLoading = false;
      });
    }
  }

  void _showBodegaOptions(BuildContext context, dynamic bodega) {
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
                '${bodega['nombre'].toString()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(14, 54, 115, 1),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading:
                    Icon(Icons.login, color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Entrar a la bodega'),
                onTap: () {
                  Navigator.pop(context);
                  _viewBodegaContent(context, bodega);
                },
              ),
              ListTile(
                leading: Icon(Icons.visibility,
                    color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Ver información'),
                onTap: () {
                  Navigator.pop(context);
                  _viewBodegaInfo(context, bodega);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.edit, color: Color.fromRGBO(14, 54, 115, 1)),
                title: Text('Editar información'),
                onTap: () {
                  Navigator.pop(context);
                  _editBodegaInfo(context, bodega);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.delete, color: Color.fromRGBO(255, 0, 0, 1)),
                title: Text('Eliminar Bodega'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteBodega(context, bodega);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _viewBodegaContent(BuildContext context, dynamic bodega) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContenidoBodegaScreen(bodega: bodega),
      ),
    );
  }

  void _viewBodegaInfo(BuildContext context, dynamic bodega) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BodegaInfoScreen(bodega: bodega),
      ),
    );
  }

  void _editBodegaInfo(BuildContext context, dynamic bodega) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BodegaEditScreen(bodega: bodega),
      ),
    ).then((value) {
      if (value == true) {
        // Si el usuario fue editado exitosamente, actualiza la lista de usuarios
        fetchBodegas();
      }
    });
  }

  Future<void> _deleteBodega(BuildContext context, dynamic bodega) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Mostrar un diálogo de confirmación
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que quieres eliminar esta bodega?"),
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
          Uri.parse(baseURL! + 'bodega/${bodega['_id']}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          await fetchBodegas();
        } else {
          throw Exception('Failed to delete bodega: ${response.body}');
        }
      } catch (e) {
        print('Error deleting bodega: $e');
        // Usar el scaffoldMessenger capturado anteriormente
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error al eliminar la bodega')),
        );
      }
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
                    Icons.store,
                    color: Color.fromRGBO(14, 54, 115, 1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Bodegas",
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
                hintText: 'Buscar bodega...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    searchController.clear();
                    _filterBodegas();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (_) => _filterBodegas(),
            ),
          ),
        SizedBox(height: 5),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : filteredBodegas.isEmpty
                ? Center(child: Text('No se encontraron Bodegas'))
                : SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredBodegas.length,
                      itemBuilder: (context, index) {
                        final bodega = filteredBodegas[index];
                        return GestureDetector(
                          onTap: () => _showBodegaOptions(context, bodega),
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
                                        Color(0xFF2E8B57), // Verde mar oscuro
                                        Color(0xFF3CB371), // Verde mar medio
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
                                          Icon(Icons.store,
                                              color: Colors.white, size: 32),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              bodega['nombre'] ?? 'Sin nombre',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              overflow: TextOverflow
                                                  .visible, // Permite que el texto desborde y sea visible
                                              maxLines: null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Icon(Icons.category,
                                              color: Colors.white70, size: 18),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Categoria: ${bodega['categoria'] ?? 'N/A'}',
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
                                            icon: Icons.production_quantity_limits,
                                            label: 'Capacidad',
                                            value:
                                                '${bodega['cantidadProductos'] ?? 0}/${bodega['capacidad']}',
                                          ),
                                          InfoColumn(
                                            icon: Icons.warning_amber_rounded,
                                            label: 'Alerta',
                                            value: bodega['alerta'] ??
                                                'Bodega estable',
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
                  ),
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
