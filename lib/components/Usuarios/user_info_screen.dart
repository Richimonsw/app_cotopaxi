import 'package:flutter/material.dart';

class UserInfoScreen extends StatelessWidget {
  final Map<String, dynamic> usuario;

  UserInfoScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información del Usuario'),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${usuario['nombre']} ${usuario['apellido']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            InfoItem(
                icon: Icons.email,
                label: 'Email',
                value: usuario['email'] ?? 'N/A'),
            InfoItem(
                icon: Icons.credit_card,
                label: 'Cédula',
                value: usuario['cedula'] ?? 'N/A'),
            InfoItem(
                icon: Icons.phone,
                label: 'Teléfono',
                value: usuario['telefono'] ?? 'N/A'),
            InfoItem(
                icon: Icons.person,
                label: 'Rol',
                value: usuario['rol'] ?? 'N/A'),
            InfoItem(
                icon: Icons.home,
                label: 'Albergue',
                value: usuario['albergue']['nombre'] ?? 'N/A'),
            // Añade más campos según sea necesario
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
