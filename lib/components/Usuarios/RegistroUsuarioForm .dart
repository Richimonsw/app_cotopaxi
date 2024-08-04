import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegistroUsuarioForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final nombreController = useTextEditingController();
    final apellidoController = useTextEditingController();
    final emailController = useTextEditingController();
    final cedulaController = useTextEditingController();
    final passwordController = useTextEditingController();
    final telefonoController = useTextEditingController();
    final rolController = useTextEditingController();
    final albergueController = useTextEditingController();
    final isLoading = useState(false);
    final albergues = useState<List<dynamic>>([]);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Future<void> fetchAlbergues() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('https://bd45-201-183-161-189.ngrok-free.app/api/albergue'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        albergues.value = json.decode(response.body);
      } else {
        throw Exception('Failed to load albergues');
      }
    }

    useEffect(() {
      fetchAlbergues();
      return;
    }, []);

    Future<void> submitForm() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(
            'https://f18c-201-183-161-189.ngrok-free.app/api/usuario/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nombre': nombreController.text,
          'apellido': apellidoController.text,
          'email': emailController.text,
          'cedula': cedulaController.text,
          'password': passwordController.text,
          'telefono': telefonoController.text,
          'rol': rolController.text,
          'albergue': albergueController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario registrado exitosamente')),
        );
        Navigator.pop(context); // Redirigir a la pestaña anterior
      } else {
        final error = json.decode(response.body)['error'];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(error),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
      ),
      body: isLoading.value
          ? Center(child: SpinKitFadingCircle(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextFormField(
                        controller: nombreController,
                        labelText: 'Nombres',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su nombre';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: apellidoController,
                        labelText: 'Apellidos',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su apellido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: emailController,
                        labelText: 'Email',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su email';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value)) {
                            return 'Por favor ingrese un email válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: cedulaController,
                        labelText: 'Cedula',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su cédula';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: passwordController,
                        labelText: 'Password',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su contraseña';
                          } else if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: telefonoController,
                        labelText: 'Telefono',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su teléfono';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildDropdownButtonFormField(
                        value: rolController.text.isEmpty
                            ? null
                            : rolController.text,
                        onChanged: (value) {
                          rolController.text = value!;
                        },
                        labelText: 'Rol',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor seleccione su rol';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildDropdownButtonFormField(
                        value: albergueController.text.isEmpty
                            ? null
                            : albergueController.text,
                        onChanged: (value) {
                          albergueController.text = value!;
                        },
                        labelText: 'Albergue',
                        items: albergues.value
                            .map<DropdownMenuItem<String>>((albergue) {
                          return DropdownMenuItem<String>(
                            value: albergue['_id'],
                            child: Text(albergue['nombre']),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isLoading.value
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  isLoading.value = true;
                                  await submitForm();
                                  isLoading.value = false;
                                }
                              },
                        child: Text('Registrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownButtonFormField({
    required String? value,
    required void Function(String?) onChanged,
    required String labelText,
    required List<DropdownMenuItem<String>> items,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      items: items,
      validator: validator,
    );
  }
}
