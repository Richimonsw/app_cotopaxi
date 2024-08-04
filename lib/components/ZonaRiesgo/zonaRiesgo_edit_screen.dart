import 'package:flutter/material.dart';

class ZonaRiesgoEditScreen extends StatefulWidget {
  final Map<String, dynamic> zonaRiesgo;

  ZonaRiesgoEditScreen({Key? key, required this.zonaRiesgo}) : super(key: key);

  @override
  _ZonaRiesgoEditScreenState createState() => _ZonaRiesgoEditScreenState();
}

class _ZonaRiesgoEditScreenState extends State<ZonaRiesgoEditScreen> {
  late TextEditingController _nombreController;
  late bool _esZonaDeRiesgo;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.zonaRiesgo['nombre']);
    _esZonaDeRiesgo = widget.zonaRiesgo['zonaDeRiesgo'] ?? false;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Zona de riesgo'),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 20),
            Text('¿Es zona de riesgo?', style: TextStyle(fontSize: 16)),
            Switch(
              value: _esZonaDeRiesgo,
              onChanged: (value) {
                setState(() {
                  _esZonaDeRiesgo = value;
                });
              },
              activeColor: Color.fromRGBO(14, 54, 115, 1),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Guardar Cambios'),
              onPressed: () {
                // Aquí implementarías la lógica para guardar los cambios
                // Por ejemplo:
                final updatedZonaRiesgo = {
                  ...widget.zonaRiesgo,
                  'nombre': _nombreController.text,
                  'zonaDeRiesgo': _esZonaDeRiesgo,
                };
                // Aquí podrías enviar updatedZonaRiesgo a tu backend

                Navigator.pop(context, updatedZonaRiesgo);
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
