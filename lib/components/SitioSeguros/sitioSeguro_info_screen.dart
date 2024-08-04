import 'package:flutter/material.dart';

class SitioSeguroInfoScreen extends StatelessWidget {
  final Map<String, dynamic> sitioSeguro;

  SitioSeguroInfoScreen({Key? key, required this.sitioSeguro})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información del Sitio Seguro'),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sitioSeguro['nombre']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            InfoItem(
                icon: Icons.location_on,
                label: 'Coordenadas X',
                value: sitioSeguro['cordenadas_x']?.toString() ?? 'N/A'),
            InfoItem(
                icon: Icons.location_on,
                label: 'Coordenadas Y',
                value: sitioSeguro['cordenadas_y']?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
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
