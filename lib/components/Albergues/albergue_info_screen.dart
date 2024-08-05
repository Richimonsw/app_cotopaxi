import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbergueInfoScreen extends StatefulWidget {
  final Map<String, dynamic> albergue;

  AlbergueInfoScreen({Key? key, required this.albergue}) : super(key: key);

  @override
  _AlbergueInfoScreenState createState() => _AlbergueInfoScreenState();
}

class _AlbergueInfoScreenState extends State<AlbergueInfoScreen> {
  final String? baseURL = dotenv.env['BaseURL'];
  String? qrCodeUrl;

  @override
  void initState() {
    super.initState();
    fetchQRCodeUrl();
  }

  Future<void> fetchQRCodeUrl() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(baseURL! + 'albergue/${widget.albergue['_id']}/qr'),
        headers: {
          'Authorization':
              'Bearer $token', // Implementa getToken() para obtener el token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          qrCodeUrl = data['url'];
        });
      } else {
        print('Failed to load QR code URL');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información del Albergue',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '${widget.albergue['nombre']}',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            SectionTitle(title: 'Código QR'),
            if (qrCodeUrl != null)
              Center(
                child: QrImageView(
                  data: qrCodeUrl!,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              )
            else
              Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
            SectionTitle(title: 'Detalles del Albergue'),
            Center(
              child: Column(
                children: [
                  InfoCounter(
                    icon: Icons.people,
                    label: 'Ciudadanos',
                    current:
                        widget.albergue['ciudadanosCount']?.toString() ?? 'N/A',
                    max: widget.albergue['capacidadCiudadanos']?.toString() ??
                        'N/A',
                  ),
                  InfoCounter(
                    icon: Icons.store,
                    label: 'Bodegas',
                    current:
                        widget.albergue['bodegasCount']?.toString() ?? 'N/A',
                    max: widget.albergue['capacidadBodegas']?.toString() ??
                        'N/A',
                  ),
                  InfoCounter(
                    icon: Icons.person,
                    label: 'Usuarios',
                    current:
                        widget.albergue['usuariosCount']?.toString() ?? 'N/A',
                    max: widget.albergue['capacidadUsuarios']?.toString() ??
                        'N/A',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SectionTitle(title: 'Ubicación'),
            InfoCard(
              icon: Icons.location_on,
              label: 'Cordenadas X',
              value: widget.albergue['cordenadas_x']?.toString() ?? 'N/A',
            ),
            InfoCard(
              icon: Icons.location_on,
              label: 'Cordenadas Y',
              value: widget.albergue['cordenadas_y']?.toString() ?? 'N/A',
            ),
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
        style: TextStyle(
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
      elevation: 5,
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
                  Text(
                    label,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCounter extends StatelessWidget {
  final IconData icon;
  final String label;
  final String current;
  final String max;

  const InfoCounter(
      {Key? key,
      required this.icon,
      required this.label,
      required this.current,
      required this.max})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Color.fromRGBO(14, 54, 115, 0.8), size: 30),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Actual: $current',
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      Text(
                        'Máximo: $max',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
