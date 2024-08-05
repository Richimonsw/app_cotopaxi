import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class QRScannerScreen extends StatefulWidget {
  final String bodegaId;

  QRScannerScreen({Key? key, required this.bodegaId}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final String? baseURL = dotenv.env['BaseURL'];
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  String? scanResult;
  final player = AudioPlayer();

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning) {
        _handleQRScan(scanData.code);
      }
    });
  }

  Future<void> _handleQRScan(String? result) async {
    if (result != null && isScanning) {
      setState(() {
        isScanning = false;
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        if (token == null) {
          throw Exception('Token no encontrado');
        }

        final response = await http.post(
          Uri.parse(baseURL! +  'productos/actualizarProductoPorQR'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'qrData': result,
            'bodegaId': widget.bodegaId,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'error') {
            _playError();
            setState(() => scanResult = 'error');
          } else {
            _playSuccess();
            setState(() => scanResult = 'success');
          }
        } else {
          throw Exception('Failed to process QR');
        }
      } catch (e) {
        print('Error processing QR: $e');
        _playError();
        setState(() => scanResult = 'error');
      }

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          scanResult = null;
          isScanning = true;
        });
      });
    }
  }

  void _playSuccess() {
    player.play(AssetSource('success.wav'));
  }

  void _playError() {
    player.play(AssetSource('error.wav'));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Código QR'),
      ),
      body: Column(
        children: [
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
              child: scanResult != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          scanResult == 'success' ? Icons.check_circle : Icons.error,
                          size: 50,
                          color: scanResult == 'success' ? Colors.green : Colors.red,
                        ),
                        Text(
                          scanResult == 'success'
                              ? 'Producto escaneado correctamente'
                              : 'Error al escanear el producto',
                        ),
                      ],
                    )
                  : Text('Escanee un código QR'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}