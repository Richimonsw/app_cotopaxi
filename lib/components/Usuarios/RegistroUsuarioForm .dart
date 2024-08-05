import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegistroUsuarioForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final String? baseURL = dotenv.env['BaseURL'];  
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
        Uri.parse(baseURL! + 'albergue'),
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
        Uri.parse(baseURL! + 'usuario/register'),
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
        Navigator.pop(context, true); // Redirigir a la pestaña anterior
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
                          } else if (!RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(value)) {
                            return 'Solo se permiten letras';
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
                          } else if (!RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(value)) {
                            return 'Solo se permiten letras';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: emailController,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
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
                        labelText: 'Cédula',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su cédula';
                          } else if (value.length != 10) {
                            return 'La cédula debe tener 10 dígitos';
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
                        labelText: 'Teléfono',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su teléfono';
                          } else if (value.length != 10) {
                            return 'El teléfono debe tener 10 dígitos';
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
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
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
