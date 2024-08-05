import 'package:flutter/material.dart';
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
        Uri.parse(
            'http://10.0.2.2:5000/api/albergue/${widget.albergue['_id']}'),
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
        title: Text('Editar Albergue'),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _cordenadasXController,
              decoration: InputDecoration(labelText: 'Cordenadas X'),
            ),
            TextField(
              controller: _cordenadasYController,
              decoration: InputDecoration(labelText: 'Cordenadas Y'),
            ),
            TextField(
              controller: ciudadanosMaxController,
              decoration: InputDecoration(labelText: 'Capacidad de ciudadanos'),
            ),
            TextField(
              controller: usuariosMaxController,
              decoration: InputDecoration(labelText: 'Capacidad de usuarios'),
            ),
            TextField(
              controller: bodegasMaxController,
              decoration: InputDecoration(labelText: 'Capacidad de bodegas'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Guardar Cambios'),
              onPressed: () {
                _editAlbergue(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(14, 54, 115, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
