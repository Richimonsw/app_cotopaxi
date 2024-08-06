import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZonaRiesgoEditScreen extends StatefulWidget {
  final Map<String, dynamic> zonaRiesgo;

  ZonaRiesgoEditScreen({Key? key, required this.zonaRiesgo}) : super(key: key);

  @override
  _ZonaRiesgoEditScreenState createState() => _ZonaRiesgoEditScreenState();
}

class _ZonaRiesgoEditScreenState extends State<ZonaRiesgoEditScreen> {
  final String? baseURL = dotenv.env['BaseURL'];
  late TextEditingController _nombreController;
  late bool _esZonaDeRiesgo;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.zonaRiesgo['nombre']);
    _esZonaDeRiesgo = widget.zonaRiesgo['zonaDeRiesgo'] ?? false;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _editZonaRiesgo(BuildContext context) async {
    final updatedZonaRiesgo = {
      ...widget.zonaRiesgo,
      'nombre': _nombreController.text,
      'zonaDeRiesgo': _esZonaDeRiesgo,
    };

    final fieldsToRemove = [
      '_id',
      'createdAt',
      'updatedAt',
      '__v',
    ];

    for (var field in fieldsToRemove) {
      updatedZonaRiesgo.remove(field);
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse(baseURL! + 'domicilios/${widget.zonaRiesgo['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedZonaRiesgo),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zona de riesgo actualizada exitosamente')),
        ); // Redirigir a la pestaña anterior
      } else {
        throw Exception('Failed to update zona de riesgo: ${response.body}');
      }
    } catch (e) {
      print('Error updating zona de riesgo: $e');
    }
    Navigator.pop(context, true); // Redirigir a la pestaña anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Zona de riesgo',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _buildTextField(_nombreController, 'Nombre', TextInputType.text),
            SizedBox(height: 20),
            Text('¿Es zona de riesgo?', style: TextStyle(fontSize: 16)),
            Switch(
              value: _esZonaDeRiesgo,
              onChanged: (value) {
                setState(() {
                  _esZonaDeRiesgo = value;
                });
              },
              activeColor: Color.fromRGBO(14, 54, 115, 1),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                child: Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  _editZonaRiesgo(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Color.fromRGBO(14, 54, 115, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType inputType, {
    bool enabled = true,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        enabled: enabled,
      ),
      keyboardType: inputType,
      inputFormatters: [
        if (inputType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
    );
  }
}
