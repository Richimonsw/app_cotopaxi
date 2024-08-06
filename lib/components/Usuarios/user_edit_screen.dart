import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final String? baseURL = dotenv.env['BaseURL'];
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
    _apellidoController =
        TextEditingController(text: widget.usuario['apellido']);
    _emailController = TextEditingController(text: widget.usuario['email']);
    _cedulaController = TextEditingController(text: widget.usuario['cedula']);
    _telefonoController =
        TextEditingController(text: widget.usuario['telefono']);
    _rolController = TextEditingController(text: widget.usuario['rol']);
    _albergueController =
        TextEditingController(text: widget.usuario['albergue']['nombre']);

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
      Uri.parse(baseURL! + 'albergue'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        albergues = json.decode(response.body);
        if (!albergues
            .any((albergue) => albergue['_id'] == _selectedAlbergue)) {
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
        Uri.parse(baseURL! + 'usuario/${widget.usuario['_id']}'),
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
        title: Text(
          'Editar Usuario',
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
              'Información Personal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(14, 54, 115, 1),
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(_nombreController, 'Nombre', TextInputType.text),
            SizedBox(height: 16),
            _buildTextField(
                _apellidoController, 'Apellido', TextInputType.text),
            SizedBox(height: 16),
            _buildTextField(
                _emailController, 'Email', TextInputType.emailAddress),
            SizedBox(height: 16),
            _buildTextField(_cedulaController, 'Cédula', TextInputType.number,
                enabled: false, maxLength: 10),
            SizedBox(height: 16),
            _buildTextField(
                _telefonoController, 'Teléfono', TextInputType.number,
                maxLength: 10),
            SizedBox(height: 32),
            Text(
              'Detalles del Rol',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(14, 54, 115, 1),
              ),
            ),
            SizedBox(height: 16),
            _buildDropdownField(
              'Rol',
              _rolController.text.isEmpty ? null : _rolController.text,
              (value) {
                setState(() {
                  _rolController.text = value!;
                });
              },
              [
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
            SizedBox(height: 16),
            _buildDropdownField(
              'Albergue',
              _selectedAlbergue,
              (value) {
                setState(() {
                  _selectedAlbergue = value;
                });
              },
              albergues.map<DropdownMenuItem<String>>((albergue) {
                return DropdownMenuItem<String>(
                  value: albergue['_id'],
                  child: Text(albergue['nombre']),
                );
              }).toList(),
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
                  _editUser(context);
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

  Widget _buildDropdownField(
    String label,
    String? value,
    ValueChanged<String?>? onChanged,
    List<DropdownMenuItem<String>> items,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      items: items,
    );
  }
}
