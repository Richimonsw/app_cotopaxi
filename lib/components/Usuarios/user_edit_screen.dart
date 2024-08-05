import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserEditScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  UserEditScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _cedulaController;
  late TextEditingController _telefonoController;
  late TextEditingController _rolController;
  late TextEditingController _albergueController;
  var albergues = [];
  String? _selectedAlbergue;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario['nombre']);
    _apellidoController = TextEditingController(text: widget.usuario['apellido']);
    _emailController = TextEditingController(text: widget.usuario['email']);
    _cedulaController = TextEditingController(text: widget.usuario['cedula']);
    _telefonoController = TextEditingController(text: widget.usuario['telefono']);
    _rolController = TextEditingController(text: widget.usuario['rol']);
    _albergueController = TextEditingController(text: widget.usuario['albergue']['nombre']);

    _selectedAlbergue = widget.usuario['albergue']['_id'];
    
    fetchAlbergues();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _rolController.dispose();
    _albergueController.dispose();
    super.dispose();
  }

  Future<void> fetchAlbergues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/albergue'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        albergues = json.decode(response.body);
        if (!albergues.any((albergue) => albergue['_id'] == _selectedAlbergue)) {
          _selectedAlbergue = null;
        }
      });
    } else {
      throw Exception('Failed to load albergues');
    }
  }

  Future<void> _editUser(BuildContext context) async {
    final updatedUser = {
      ...widget.usuario,
      'nombre': _nombreController.text,
      'apellido': _apellidoController.text,
      'email': _emailController.text,
      'cedula': _cedulaController.text,
      'telefono': _telefonoController.text,
      'rol': _rolController.text,
      'albergue': _selectedAlbergue,
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/usuario/${widget.usuario['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedUser),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario actualizado exitosamente')),
        );
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      print('Error updating user: $e');
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuario'),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: _apellidoController,
              decoration: InputDecoration(labelText: 'Apellido'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _cedulaController,
              decoration: InputDecoration(
                labelText: 'Cédula',
                enabled: false,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _rolController.text.isEmpty ? null : _rolController.text,
              onChanged: (value) {
                setState(() {
                  _rolController.text = value!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Rol',
              ),
              items: [
                DropdownMenuItem(
                  value: 'admin_zonal',
                  child: Text('Admin Zonal'),
                ),
                DropdownMenuItem(
                  value: 'admin_farmaceutico',
                  child: Text('Admin Farmacéutico'),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _selectedAlbergue,
              onChanged: (value) {
                setState(() {
                  _selectedAlbergue = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Albergue',
              ),
              items: albergues.map<DropdownMenuItem<String>>((albergue) {
                return DropdownMenuItem<String>(
                  value: albergue['_id'],
                  child: Text(albergue['nombre']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Guardar Cambios'),
              onPressed: () {
                _editUser(context);
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
