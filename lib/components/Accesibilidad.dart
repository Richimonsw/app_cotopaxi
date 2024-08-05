import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Accesibilidad extends StatefulWidget {
  @override
  _AccesibilidadState createState() => _AccesibilidadState();
}

class _AccesibilidadState extends State<Accesibilidad> {
  final String? baseURL = dotenv.env['BaseURL'];
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String result = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.app_registration,
                color: Color.fromRGBO(14, 54, 115, 1),
                size: 24,
              ),
              SizedBox(width: 2),
              Text(
                "Vinculación",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(14, 54, 115, 1),
                ),
              ),
            ],
          ),
        ),
        Card(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IntrinsicHeight(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showQRScanner(context);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                color: Colors.transparent,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(1),
                                  child: Column(
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        elevation: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(7),
                                          child: Image.asset(
                                            'assets/icon/setting.png',
                                            width: 80,
                                            height: 80,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(result),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showQRScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text('Escanea el código QR del ciudadano'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      _processScanResult(scanData.code);
    });
  }

  void _processScanResult(String? scanData) async {
    if (scanData != null) {
      try {
        print(scanData);

        
        Map<String, dynamic> ciudadanoData = json.decode(scanData);
        await _updateCiudadano(ciudadanoData);
        setState(() {
          result = "Ciudadano actualizado con éxito";
        });
      } catch (e) {
        print("Error al procesar los datos: $e");
        setState(() {
          result = "Error al procesar los datos: $e";
        });
      }
    }
    Navigator.pop(context);
  }

  Future<void> _updateCiudadano(Map<String, dynamic> ciudadanoData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    final response = await http.post(
      Uri.parse(baseURL! + 'ciudadano/scanQrCode'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'ciudadanoData': ciudadanoData,
      }),
    );

    if (response.statusCode == 200) {
      print('Ciudadano actualizado con éxito');
    } else {
      print('Error del servidor: ${response.statusCode} ${response.body}');
      throw Exception('Failed to update ciudadano');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
