import 'package:app_cotopaxi/components/Albergues/Administradores.dart';
import 'package:app_cotopaxi/components/Albergues/Bodegas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ContenidoScreen extends StatefulWidget {
  final Map<String, dynamic> albergue;

  ContenidoScreen({Key? key, required this.albergue}) : super(key: key);

  @override
  _ContenidoScreenState createState() => _ContenidoScreenState();
}

class _ContenidoScreenState extends State<ContenidoScreen> {
  final String? baseURL = dotenv.env['BaseURL'];
  List<dynamic> ciudadanos = [];
  bool isLoading = false;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchCiudadanos();
  }

  Future<void> _fetchCiudadanos() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }

      final albergueId = widget.albergue['_id']?.toString();
      if (albergueId == null) {
        throw Exception('Albergue ID is null');
      }

      final response = await http.get(
        Uri.parse(baseURL! +  'ciudadano/$albergueId/ciudadanos'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          ciudadanos = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load ciudadanos');
      }
    } catch (e) {
      print('Error fetching ciudadanos: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar ciudadanos')),
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    String albergueId = widget.albergue['_id']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albergue['nombre']?.toString() ?? 'Albergue'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Administradores(albergueId: albergueId),
              Bodegas(albergueId: albergueId),
              SizedBox(height: 20),
              Text(
                'Ciudadanos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, cedula',
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
              SizedBox(height: 20),
              isLoading ? CircularProgressIndicator() : _buildCiudadanosTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCiudadanosTable() {
    final filteredCiudadanos = ciudadanos
        .where((ciudadano) =>
            ciudadano['cedula']
                ?.toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()) ??
            false)
        .toList();

    final columns = [
      {'title': 'Nombre', 'dataIndex': 'nombre'},
      {'title': 'Apellido', 'dataIndex': 'apellido'},
      {'title': 'Edad', 'dataIndex': 'edad'},
      {'title': 'Teléfono', 'dataIndex': 'telefono'},
      {'title': 'Cedula', 'dataIndex': 'cedula'},
      {'title': 'Email', 'dataIndex': 'email'},
      {'title': 'Enfermedades', 'dataIndex': 'enfermedades'},
      {'title': 'Medicamentos', 'dataIndex': 'medicamentos'},
      {'title': 'Acciones', 'dataIndex': 'acciones'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map((column) => DataColumn(
                  label: Text(column['title']!),
                ))
            .toList(),
        rows: filteredCiudadanos.map((ciudadano) {
          return DataRow(
            cells: columns.map((column) {
              final value = ciudadano[column['dataIndex']]?.toString() ?? 'N/A';
              if (column['dataIndex'] == 'medicamentos') {
                // Asumiendo que medicamentos es una lista
                final medicamentos =
                    (ciudadano['medicamentos'] as List?)?.join(', ') ?? 'N/A';
                return DataCell(Text(medicamentos));
              } else if (column['dataIndex'] == 'acciones') {
                return DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => handleEdit(ciudadano),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => handleDelete(ciudadano),
                      ),
                    ],
                  ),
                );
              } else {
                return DataCell(Text(value));
              }
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

void handleEdit(Map<String, dynamic> ciudadano) {
  // Implementa la lógica de edición aquí
}

void handleDelete(Map<String, dynamic> ciudadano) {
  // Implementa la lógica de eliminación aquí
}
