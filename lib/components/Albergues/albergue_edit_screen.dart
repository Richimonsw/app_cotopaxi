import 'package:flutter/material.dart';

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
