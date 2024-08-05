import 'package:app_cotopaxi/components/Bodegas/bodega_edit_screen.dart';
import 'package:app_cotopaxi/components/Bodegas/bodega_info_screen.dart';
import 'package:app_cotopaxi/components/Bodegas/contenidoBodega_screen.dart';
import 'package:flutter/material.dart';
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
  List<dynamic> bodegas = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchBodegas();
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
        Uri.parse(
            'http://10.0.2.2:5000/api/bodega/${widget.albergueId}/bodegas'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bodegas = data['data'];
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
          Uri.parse('http://10.0.2.2:5000/api/bodega/${bodega['_id']}'),
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
                    Icons.home_repair_service,
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
            ],
          ),
        ),
        SizedBox(height: 5),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : bodegas.isEmpty
                ? Center(child: _buildNoBodegas())
                : SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: bodegas.length,
                      itemBuilder: (context, index) {
                        final bodega = bodegas[index];
                        return GestureDetector(
                          onTap: () => _showBodegaOptions(context, bodega),
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
                                      '${bodega['nombre'].toString()}' ??
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
                                      label: 'Categoria',
                                      value: bodega['categoria'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.credit_card,
                                      label: 'Capacidad',
                                      value: bodega['capacidad'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.phone,
                                      label: 'cantidadProductos',
                                      value:
                                          bodega['cantidadProductos'] ?? 'N/A',
                                    ),
                                    SizedBox(height: 8),
                                    InfoRow(
                                      icon: Icons.person,
                                      label: 'Alerta',
                                      value:
                                          bodega['alerta'] ?? 'Bodega estable',
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

  Widget _buildNoBodegas() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.exclamationCircle,
                color: Colors.yellow[700], size: 48),
            SizedBox(height: 8),
            Text(
              'No hay ninguna bodega asignada al albergue todavía.',
              style: TextStyle(color: Colors.yellow[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
