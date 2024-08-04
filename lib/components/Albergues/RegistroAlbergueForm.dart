import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegistroAlbergueForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final nombreController = useTextEditingController();
    final cordenadasXController = useTextEditingController();
    final cordenadasYController = useTextEditingController();
    final ciudadanosMaxController = useTextEditingController();
    final usuariosMaxController = useTextEditingController();
    final bodegasMaxController = useTextEditingController();
    final isLoading = useState(false);
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Future<void> submitForm() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(
            'https://bd45-201-183-161-189.ngrok-free.app/api/albergue/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nombre': nombreController.text,
          'capacidadCiudadanos': ciudadanosMaxController.text,
          'capacidadBodegas': bodegasMaxController.text,
          'capacidadUsuarios': usuariosMaxController.text,
          'cordenadas_x': cordenadasXController.text,
          'cordenadas_y': cordenadasYController.text,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Albergue registrado exitosamente')),
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
        title: Text('Registro de Albergue'),
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
                        controller: cordenadasXController,
                        labelText: 'Cordenadas X',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la cordenada X';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: cordenadasYController,
                        labelText: 'Cordenadas Y',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la cordenadas y';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: ciudadanosMaxController,
                        labelText: 'Capacidad de ciudadanos',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la capacidad de ciudadanos';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: usuariosMaxController,
                        labelText: 'Capacidad de usuarios',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la capacidad de usuarios';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: bodegasMaxController,
                        labelText: 'Capacidad de bodegas',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la capacidad de bodegas';
                          }
                          return null;
                        },
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
                        child: Text('Crear'),
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
