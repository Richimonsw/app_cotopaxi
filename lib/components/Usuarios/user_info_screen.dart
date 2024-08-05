import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserInfoScreen extends StatelessWidget {
  final Map<String, dynamic> usuario;

  UserInfoScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Información del Usuario',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/icon/setting.png'),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                '${usuario['nombre']} ${usuario['apellido']}',
                style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            SectionTitle(title: 'Información Personal'),
            InfoCard(
                icon: Icons.email,
                label: 'Email',
                value: usuario['email'] ?? 'N/A'),
            InfoCard(
                icon: Icons.credit_card,
                label: 'Cédula',
                value: usuario['cedula'] ?? 'N/A'),
            InfoCard(
                icon: Icons.phone,
                label: 'Teléfono',
                value: usuario['telefono'] ?? 'N/A'),
            SizedBox(height: 20),
            SectionTitle(title: 'Información del Rol'),
            InfoCard(
                icon: Icons.person,
                label: 'Rol',
                value: usuario['rol'] ?? 'N/A'),
            InfoCard(
                icon: Icons.home,
                label: 'Albergue',
                value: usuario['albergue']['nombre'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(14, 54, 115, 1),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoCard(
      {Key? key, required this.icon, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Color.fromRGBO(14, 54, 115, 0.8), size: 30),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.lato(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(value, style: GoogleFonts.lato(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
