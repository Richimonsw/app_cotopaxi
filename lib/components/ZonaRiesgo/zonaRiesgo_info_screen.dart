import 'package:flutter/material.dart';

class ZonaRiesgoInfoScreen extends StatelessWidget {
  final Map<String, dynamic> zonaRiesgo;

  ZonaRiesgoInfoScreen({Key? key, required this.zonaRiesgo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de zona de riesgo'),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${zonaRiesgo['nombre']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            InfoItem(
                icon: Icons.warning,
                label: 'Zona de riesgo',
                value: _formatBooleanValue(zonaRiesgo['zonaDeRiesgo'])),
          ],
        ),
      ),
    );
  }

  String _formatBooleanValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is bool) {
      return value ? 'Sí' : 'No';
    }
    return value.toString();
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoItem(
      {Key? key, required this.icon, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color.fromRGBO(14, 54, 115, 0.8)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(value, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
