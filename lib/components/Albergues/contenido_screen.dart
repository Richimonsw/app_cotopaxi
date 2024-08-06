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

      if (baseURL == null) {
        throw Exception('Base URL is null');
      }

      final response = await http.get(
        Uri.parse(baseURL! + 'ciudadano/$albergueId/ciudadanos'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> ciudadanosData = json.decode(response.body);
        setState(() {
          ciudadanos = ciudadanosData;
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
        SnackBar(content: Text('Error al cargar ciudadanos: $e')),
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
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o cédula',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 400, // Ajusta el tamaño según sea necesario
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildCiudadanosTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCiudadanosTable() {
    final filteredCiudadanos = ciudadanos
        .where((ciudadano) =>
            ciudadano['nombre']
                ?.toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()) ??
            false || ciudadano['cedula']
                !.toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()) ??
            false)
        .toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredCiudadanos.length,
      itemBuilder: (context, index) {
        final ciudadano = filteredCiudadanos[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ExpansionTile(
            title: Text(
              '${ciudadano['nombre']} ${ciudadano['apellido']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Cédula: ${ciudadano['cedula']}'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                        'Edad', ciudadano['edad'].toString(), Icons.cake),
                    _buildInfoRow('Email', ciudadano['email'], Icons.email),
                    _buildInfoRow(
                        'Enfermedades',
                        (ciudadano['enfermedades'] as List?)?.join(', ') ??
                            'N/A',
                        Icons.medical_services),
                    _buildInfoRow(
                        'Medicamentos',
                        (ciudadano['medicamentos'] as List?)?.join(', ') ??
                            'N/A',
                        Icons.medication),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
