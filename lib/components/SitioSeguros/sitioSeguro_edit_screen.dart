import 'package:flutter/material.dart';

class SitioSeguroEditScreen extends StatefulWidget {
  final Map<String, dynamic> sitioSeguro;

  SitioSeguroEditScreen({Key? key, required this.sitioSeguro})
      : super(key: key);

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<SitioSeguroEditScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _cordenadaXController;
  late TextEditingController _cordenadaYController;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.sitioSeguro['nombre']);
    _cordenadaXController = TextEditingController(
        text: widget.sitioSeguro['cordenadas_x']?.toString());
    _cordenadaYController = TextEditingController(
        text: widget.sitioSeguro['cordenadas_y']?.toString());
    ;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cordenadaXController.dispose();
    _cordenadaYController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Sitio Seguro'),
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
              controller: _cordenadaXController,
              decoration: InputDecoration(labelText: 'Cordenada X'),
            ),
            TextField(
              controller: _cordenadaYController,
              decoration: InputDecoration(labelText: 'Cordenada Y'),
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
