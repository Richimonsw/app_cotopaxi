import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AlbergueEditScreen extends StatefulWidget {
  final Map<String, dynamic> albergue;

  AlbergueEditScreen({Key? key, required this.albergue}) : super(key: key);

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<AlbergueEditScreen> {
  final String? baseURL = dotenv.env['BaseURL'];
  late TextEditingController _nombreController;
  late TextEditingController _cordenadasXController;
  late TextEditingController _cordenadasYController;
  late TextEditingController ciudadanosMaxController;
  late TextEditingController usuariosMaxController;
  late TextEditingController bodegasMaxController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.albergue['nombre']);
    _cordenadasXController = TextEditingController(
        text: widget.albergue['cordenadas_x']?.toString());
    _cordenadasYController = TextEditingController(
        text: widget.albergue['cordenadas_y']?.toString());
    ciudadanosMaxController = TextEditingController(
        text: widget.albergue['capacidadCiudadanos']?.toString());
    usuariosMaxController = TextEditingController(
        text: widget.albergue['capacidadBodegas']?.toString());
    bodegasMaxController = TextEditingController(
        text: widget.albergue['capacidadUsuarios']?.toString());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cordenadasXController.dispose();
    _cordenadasYController.dispose();
    ciudadanosMaxController.dispose();
    usuariosMaxController.dispose();
    bodegasMaxController.dispose();
    super.dispose();
  }

  Future<void> _editAlbergue(BuildContext context) async {
    final updatedAlbergue = {
      ...widget.albergue,
      'nombre': _nombreController.text,
      'capacidadCiudadanos': ciudadanosMaxController.text,
      'capacidadBodegas': bodegasMaxController.text,
      'capacidadUsuarios': usuariosMaxController.text,
      'cordenadas_x': _cordenadasXController.text,
      'cordenadas_y': _cordenadasYController.text,
    };

    final fieldsToRemove = [
      '_id',
      'ciudadanos',
      'usuarios',
      'bodegas',
      'createdAt',
      'updatedAt',
      '__v',
      'ciudadanosCount',
      'usuariosCount',
      'bodegasCount'
    ];

    for (var field in fieldsToRemove) {
      updatedAlbergue.remove(field);
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse(baseURL! + 'albergue/${widget.albergue['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedAlbergue),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Albergue actualizada exitosamente')),
        );
      } else {
        throw Exception('Failed to update albergue: ${response.body}');
      }
    } catch (e) {
      print('Error updating albergue: $e');
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Albergue',
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
            Text(
              'Detalles del Albergue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(14, 54, 115, 1),
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(_nombreController, 'Nombre', TextInputType.number),
            SizedBox(height: 16),
            _buildTextField(
                ciudadanosMaxController, 'Capacidad de ciudadanos', TextInputType.number),
            SizedBox(height: 16),
            _buildTextField(
                usuariosMaxController, 'Capacidad de usuarios', TextInputType.number),
            SizedBox(height: 16),
            _buildTextField(
                bodegasMaxController, 'Capacidad de bodegas', TextInputType.number),
            SizedBox(height: 16),
            Text(
              'Ubicacion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(14, 54, 115, 1),
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(_cordenadasXController, 'Cordenadas X', TextInputType.text),
            SizedBox(height: 16),
            _buildTextField(
                _cordenadasYController, 'Cordenadas Y', TextInputType.text),
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
                  _editAlbergue(context);
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
