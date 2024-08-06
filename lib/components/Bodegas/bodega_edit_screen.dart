import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BodegaEditScreen extends StatefulWidget {
  final Map<String, dynamic> bodega;

  BodegaEditScreen({Key? key, required this.bodega}) : super(key: key);

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<BodegaEditScreen> {
  final String? baseURL = dotenv.env['BaseURL'];
  late TextEditingController _nombreController;
  late TextEditingController _categoriaController;
  late TextEditingController _capacidadController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.bodega['nombre']);
    _categoriaController =
        TextEditingController(text: widget.bodega['categoria']?.toString());
    _capacidadController =
        TextEditingController(text: widget.bodega['capacidad']?.toString());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  Future<void> _editBodega(BuildContext context) async {
    final updatedBodega = {
      ...widget.bodega,
      'nombre': _nombreController.text,
      'categoria': _categoriaController.text,
      'capacidad': _capacidadController.text,
    };

    final fieldsToRemove = [
      '_id',
      'createdAt',
      'updatedAt',
      '__v',
      'productos',
      'cantidadProductos',
      'alerta',
      'porcentajeOcupacion',
    ];

    for (var field in fieldsToRemove) {
      updatedBodega.remove(field);
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse(baseURL! + 'bodega/${widget.bodega['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedBodega),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bodega actualizada exitosamente')),
        );
      } else {
        throw Exception('Failed to update bodega: ${response.body}');
      }
    } catch (e) {
      print('Error updating bodega: $e');
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Bodega',
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
            SizedBox(height: 16),
            _buildTextField(_categoriaController, 'Categoria',
                TextInputType.text),
            SizedBox(height: 16),
            _buildTextField(_capacidadController, 'Capacidad',
                TextInputType.number),
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
                  _editBodega(context);
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
