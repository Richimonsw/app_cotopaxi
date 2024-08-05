import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ShowCiudadanos extends StatefulWidget {
  @override
  _ShowCiudadanoScreenState createState() => _ShowCiudadanoScreenState();
}

class _ShowCiudadanoScreenState extends State<ShowCiudadanos> {
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

      final response = await http.get(
        Uri.parse(baseURL! +  'ciudadano/ciudadanosDeTodosLosAlbergues/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        ciudadanos = json.decode(response.body);

        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load ciudadano');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Ciudadanos generales'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Ciudadanos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre',
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
              SizedBox(height: 20),
              isLoading ? CircularProgressIndicator() : _buildProductosTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductosTable() {
    final filteredCiudadanos = ciudadanos
        .where((ciudadano) =>
            ciudadano['nombre']
                ?.toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()) ??
            false)
        .toList();

    final columns = [
      {'title': 'Estado', 'dataIndex': 'salvaldo'},
      {'title': 'Albergue', 'dataIndex': 'albergue.nombre'},
      {'title': 'Nombre', 'dataIndex': 'nombre'},
      {'title': 'Apellido', 'dataIndex': 'apellido'},
      {'title': 'Cedula', 'dataIndex': 'cedula'},
      {'title': 'Edad', 'dataIndex': 'edad'},
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
              final dataIndex = column['dataIndex']!;
              String value = 'N/A';

              if (dataIndex.contains('.')) {
                // Acceder a propiedades anidadas
                List<String> keys = dataIndex.split('.');
                dynamic nestedValue = ciudadano;
                for (String key in keys) {
                  nestedValue = nestedValue[key];
                  if (nestedValue == null) break;
                }
                value = nestedValue?.toString() ?? 'N/A';
              } else {
                value = ciudadano[dataIndex]?.toString() ?? 'N/A';
              }

              if (dataIndex == 'medicamentos') {
                // Asumiendo que medicamentos es una lista
                final medicamentos =
                    (ciudadano['medicamentos'] as List?)?.join(', ') ?? 'N/A';
                return DataCell(Text(medicamentos));
              } else if (dataIndex == 'salvaldo') {
                value = (ciudadano['salvaldo'] == true) ? 'SALVADO' : 'NO SALVADO';
                return DataCell(Text(value));
              } else if (dataIndex == 'acciones') {
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
