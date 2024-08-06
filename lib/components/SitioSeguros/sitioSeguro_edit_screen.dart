import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SitioSeguroEditScreen extends StatefulWidget {
  final Map<String, dynamic> sitioSeguro;

  SitioSeguroEditScreen({Key? key, required this.sitioSeguro})
      : super(key: key);

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<SitioSeguroEditScreen> {
  final String? baseURL = dotenv.env['BaseURL'];
  late TextEditingController _nombreController;
  late TextEditingController _cordenadaXController;
  late TextEditingController _cordenadaYController;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.sitioSeguro['nombre']);
    _cordenadaXController = TextEditingController(
        text: widget.sitioSeguro['cordenadas_x']?.toString());
    _cordenadaYController = TextEditingController(
        text: widget.sitioSeguro['cordenadas_y']?.toString());
    ;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cordenadaXController.dispose();
    _cordenadaYController.dispose();
    super.dispose();
  }

  Future<void> _editSitioSeguro(BuildContext context) async {
    final updatedSitioSeguro = {
      ...widget.sitioSeguro,
      'nombre': _nombreController.text,
      'cordenadas_x': _cordenadaXController.text,
      'cordenadas_y': _cordenadaYController.text,
    };

    final fieldsToRemove = [
      '_id',
      'createdAt',
      'updatedAt',
      '__v',
    ];

    for (var field in fieldsToRemove) {
      updatedSitioSeguro.remove(field);
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse(baseURL! + 'sitioSeguro/${widget.sitioSeguro['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedSitioSeguro),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sitio seguro actualizado exitosamente')),
        );
      } else {
        throw Exception('Failed to update sitio seguro: ${response.body}');
      }
    } catch (e) {
      print('Error updating sitio seguro: $e');
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Sitio Seguro',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildTextField(_nombreController, 'Nombre', TextInputType.text),
            SizedBox(height: 16),
            _buildTextField(
                _cordenadaXController, 'Cordenadas X', TextInputType.text),
            SizedBox(height: 16),
            _buildTextField(
                _cordenadaYController, 'Cordenadas Y', TextInputType.text),
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
                  _editSitioSeguro(context);
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
