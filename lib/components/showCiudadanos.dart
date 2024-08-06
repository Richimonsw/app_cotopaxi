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
        Uri.parse(baseURL! + 'ciudadano/ciudadanosDeTodosLosAlbergues/'),
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre',
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
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildCiudadanosTable(),
          ),
        ],
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
            leading: CircleAvatar(
              backgroundColor:
                  ciudadano['salvaldo'] == true ? Colors.green : Colors.red,
              child: Icon(
                ciudadano['salvaldo'] == true ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
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
                        'Albergue',
                        ciudadano['albergue'] != null
                            ? ciudadano['albergue']['nombre']
                            : 'N/A',
                        Icons.home),
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
