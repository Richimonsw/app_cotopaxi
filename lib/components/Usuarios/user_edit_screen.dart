import 'package:flutter/material.dart';

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
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    super.dispose();
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
            ),
            TextField(
              controller: _apellidoController,
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _cedulaController,
              decoration: InputDecoration(labelText: 'Cédula'),
            ),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Teléfono'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Guardar Cambios'),
              onPressed: () {
                // Aquí implementarías la lógica para guardar los cambios
                // Por ahora, solo cerramos la pantalla
                Navigator.pop(context);
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
