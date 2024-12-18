import 'dart:convert';
import 'dart:io';
import 'package:app_cotopaxi/components/Accesibilidad.dart';
import 'package:app_cotopaxi/components/Albergues.dart';
import 'package:app_cotopaxi/components/ListCiudadanos.dart';
import 'package:app_cotopaxi/components/RegistrosRapidos.dart';
import 'package:app_cotopaxi/components/SitioSeguros.dart';
import 'package:app_cotopaxi/components/Usuarios.dart';
import 'package:app_cotopaxi/components/ZonasRiesgo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'login.dart'; // Importa la página de inicio de sesión
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String? baseURL = dotenv.env['BaseURL'];
  String _albergue = "";
  String _apellido = "";
  String _cedula = "";
  final String _defaultProfileImageUrl =
      'https://res.cloudinary.com/dlyytqayv/image/upload/v1722340906/ImagenPerfil/blfa1i6te1lwchsklrjb.jpg'; // Cambia esto por tu URL de Cloudinary

  String _imagenPath =
      ""; // Variable para almacenar la ruta de la imagen en caché

  String _nombre = "";
  String _qrImagePath = "";
  String _userRole = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    Usuarios();
  }

  // Función para cargar los datos del usuario desde SharedPreferences
  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombre = prefs.getString('nombres') ?? '';
      _apellido = prefs.getString('apellidos') ?? '';
      _albergue = prefs.getString('albergue') ?? '';
      _imagenPath = prefs.getString('imgPerfil') ?? _defaultProfileImageUrl;
      _qrImagePath = prefs.getString('qrImagePath') ?? '';
      _cedula = prefs.getString('cedula') ?? '';
      _userRole = prefs.getString('rol') ?? '';
    });
  }

  // Función para exportar los datos en PDF

  void _exportToPDF() async {
    double _progress = 0.0;
    String _filePath = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(value: _progress),
                SizedBox(height: 20),
                Text(
                    "Generando Tarjeta de Identidad: ${(_progress * 33).toStringAsFixed(0)}%"),
              ],
            ),
          );
        });
      },
    );

    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permiso de almacenamiento no concedido.')),
          );
        }
        return;
      } 

      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final PdfGraphics graphics = page.graphics;

      double cardWidth = 400;
      double cardHeight = 250;
      double xOffset = (page.getClientSize().width - cardWidth) / 2;
      double yOffset = (page.getClientSize().height - cardHeight) / 2;

      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 30,
          style: PdfFontStyle.bold);
      final PdfFont subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 18);
      final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

      graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(230, 230, 250)),
        bounds: Rect.fromLTWH(xOffset, yOffset, cardWidth, cardHeight),
        pen: PdfPen(PdfColor(75, 0, 130), width: 2),
      );

      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              _progress = 0.2;
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: _progress),
                    SizedBox(height: 20),
                    Text(
                        "Generando Tarjeta de Identidad: ${(_progress * 69).toStringAsFixed(0)}%"),
                  ],
                ),
              );
            });
          },
        );
      }

      graphics.drawString('Tarjeta de Identidad', titleFont,
          brush: PdfSolidBrush(PdfColor(75, 0, 130)),
          bounds: Rect.fromLTWH(xOffset, yOffset + 10, cardWidth, 30),
          format: PdfStringFormat(alignment: PdfTextAlignment.center));

      final PdfFont infoFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
      double textY = yOffset + 50;
      void addUserInfo(String label, String value) {
        graphics.drawString('$label: $value', infoFont,
            brush: PdfSolidBrush(PdfColor(0, 0, 0)),
            bounds: Rect.fromLTWH(xOffset + 20, textY, cardWidth - 140, 20));
        textY += 25;
      }

      addUserInfo('Nombre', '$_nombre $_apellido');
      addUserInfo('Albergue', _albergue);
      addUserInfo('Cédula', _cedula);

      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              _progress = 0.6;
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: _progress),
                    SizedBox(height: 20),
                    Text(
                        "Generando Tarjeta de Identidad: ${(_progress * 100).toStringAsFixed(0)}%"),
                  ],
                ),
              );
            });
          },
        );
      }

      if (_qrImagePath.isNotEmpty) {
        try {
          final Uint8List qrBytes = await _getImageBytes(_qrImagePath);
          final PdfBitmap qrImage = PdfBitmap(qrBytes);
          graphics.drawImage(qrImage,
              Rect.fromLTWH(xOffset + cardWidth - 120, yOffset + 50, 100, 100));
        } catch (e) {
          print('Error al cargar la imagen QR: $e');
        }
      }

      final List<int> bytes = await document.save();
      document.dispose();

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('No se pudo obtener el directorio de descargas.');
      }

      final String fileName =
          'perfil_usuario_${_nombre}_${_apellido}_$_cedula.pdf';
      _filePath = '${directory.path}/$fileName';
      final File file = File(_filePath);
      await file.writeAsBytes(bytes);

      if (Platform.isAndroid) {
        // Actualiza la base de datos de MediaStore para que el archivo sea reconocido
        final path = _filePath;
        final uri = Uri.parse(path);
        final result = await Process.run('am', [
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d',
          uri.toString()
        ]);
        print('Resultado de MediaStore: ${result.stdout}');
      }

      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('PDF Generado'),
              content: Text('El PDF se ha guardado en:\n$_filePath'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Abrir PDF'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    print('Intentando abrir el archivo: $_filePath');
                    final result = await OpenFile.open(_filePath);
                    print('Resultado de OpenFile: $result');
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('No se pudo generar el PDF: $e'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<List<int>> _loadFontData(String path) async {
    final ByteData bytes = await rootBundle.load(path);
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  Future<Uint8List> _getImageBytes(String imagePath) async {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      final response = await http.get(Uri.parse(imagePath));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image from URL');
      }
    } else if (imagePath.startsWith('assets/')) {
      return (await rootBundle.load(imagePath)).buffer.asUint8List();
    } else {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      } else {
        throw Exception('Image file not found: $imagePath');
      }
    }
  }

  // Método para editar la foto de perfil
  Future<void> _editProfileImage() async {
    final picker = ImagePicker();

    // Mostrar un diálogo para que el usuario elija entre cámara y galería
    final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Seleccionar fuente de imagen'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.camera);
                },
                child: const Text('Cámara'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
                child: const Text('Galería'),
              ),
            ],
          );
        });

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        String imageUrl = await _uploadImageToCloudinary(File(pickedFile.path));
        if (imageUrl.isNotEmpty) {
          bool success = await _updateProfileImageInDatabase(imageUrl);
          if (success) {
            setState(() {
              _imagenPath = imageUrl;
            });
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('profileImageUrl', _imagenPath);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Foto de perfil actualizada correctamente.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Error al actualizar la imagen en la base de datos.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir la imagen a Cloudinary.')),
          );
        }
      }
    }
  }

  Future<String> _uploadImageToCloudinary(File imageFile) async {
    String cloudinaryUrl =
        "https://api.cloudinary.com/v1_1/dlyytqayv/image/upload";
    String uploadPreset = "ImgPerfil"; // Reemplaza esto con tu preset de carga

    var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));
    request.fields['upload_preset'] = uploadPreset;

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);
      return jsonResponse['secure_url'];
    } else {
      return '';
    }
  }

  Future<bool> _updateProfileImageInDatabase(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cedula = prefs.getString('cedula') ?? '';
      final userRole = prefs.getString('rol') ?? '';

      final apiUrl = _getApiUrlBasedOnRole(userRole);

      print(
          "Sending updateProfileImage request with cedula: $cedula and imgPerfil: $imageUrl");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'cedula': cedula, 'imgPerfil': imageUrl}),
      );

      if (response.statusCode == 200) {
        print('Imagen de perfil actualizada en la base de datos');
        return true;
      } else {
        print(
            'Error al actualizar la imagen de perfil en la base de datos: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error inesperado: $e');
      return false;
    }
  }

  String _getApiUrlBasedOnRole(String userRole) {
    const adminRoles = ["admin_farmaceutico", "admin_zonal", "admin_general"];
    return adminRoles.contains(userRole)
        ? '${baseURL!}usuario/updateProfileImage'
        : '${baseURL!}ciudadano/updateProfileImage';
  }

  // Función para cerrar sesión
  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra todos los datos almacenados
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginPage()), // Redirige a la página de inicio de sesión
    );
  }

  // Método para mostrar el diálogo de confirmación
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text(
              '¿Está seguro de que desea cerrar sesión? No podrá iniciar sesión sin conexión a Internet.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Cierra el diálogo sin cerrar sesión
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _logout(); // Cierra la sesión
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(242, 238, 236, 1),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text('Exportar en PDF'),
                      onTap: () {
                        Navigator.pop(context); // Cierra el menú
                        _exportToPDF();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Cerrar Sesión'),
                      onTap: () {
                        Navigator.pop(context); // Cierra el menú
                        _showLogoutConfirmationDialog();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      backgroundColor: Color.fromRGBO(242, 238, 236, 1),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                  color: const Color.fromRGBO(10, 57, 130, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(14, 54, 115, 1),
                          Color.fromRGBO(54, 94, 155, 1),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius:
                                        55, // Ajusta este valor según tus necesidades
                                    backgroundImage: NetworkImage(
                                      _imagenPath.isNotEmpty
                                          ? _imagenPath
                                          : _defaultProfileImageUrl,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: Icon(Icons.camera_alt,
                                            color: Colors.black),
                                        onPressed: () {
                                          _editProfileImage();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: IconButton(
                                    icon: Icon(Icons.camera_alt,
                                        color: Colors.black),
                                    onPressed: () {
                                      _editProfileImage();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      150, // Ajusta este valor al ancho deseado para la información del usuario
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$_nombre $_apellido',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.visible,
                                        ),
                                        Text(
                                          _cedula,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (_userRole == "admin_zonal" ||
                                            _userRole == "admin_farmaceutico" ||
                                            _userRole == "admin_general")
                                          Text(
                                            _userRole,
                                            style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 250, 239, 239),
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        if (_userRole != "admin_zonal" &&
                                            _userRole != "admin_farmaceutico" &&
                                            _userRole != "admin_general")
                                          Text(
                                            'Ciudadano',
                                            style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 250, 239, 239),
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ]),
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  thickness: 1,
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_userRole != "admin_general")
                                      Container(
                                        width:
                                            100, // Ajusta este valor al ancho deseado para la información del albergue
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'ALBERGUE',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _albergue,
                                              style: TextStyle(
                                                color: const Color.fromARGB(
                                                    255, 250, 239, 239),
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.visible,
                                              maxLines:
                                                  2, // Ajusta este valor si quieres más o menos líneas
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (_userRole == "admin_general")
                                      Image.asset(
                                        'assets/icon/admin.png',
                                        width: 50,
                                        height: 50,
                                      ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
              SizedBox(height: 7),
              if (_userRole != "admin_zonal" &&
                  _userRole != "admin_farmaceutico" &&
                  _userRole != "admin_general")
                Card(
                  color: const Color.fromRGBO(235, 241, 253, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'QR Personal',
                          style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromRGBO(14, 54, 115, 1),
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        _qrImagePath.isNotEmpty
                            ? Image.file(
                                File(_qrImagePath),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.qr_code,
                                size: 150,
                                color: Colors.grey,
                              ), // Mostrar un ícono QR si no hay imagen
                      ],
                    ),
                  ),
                ),
              if (_userRole == "admin_general" ||
                  _userRole == "admin_farmaceutico" ||
                  _userRole == "admin_zonal")
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (_userRole == "admin_zonal" ||
                          _userRole == "admin_farmaceutico") ...[
                        SizedBox(height: 4),
                        Accesibilidad(),
                        Albergues(),
                      ] else if (_userRole == "admin_general") ...[
                        SizedBox(height: 3),
                        ListadoCiudadanos(),
                        SizedBox(height: 3),
                        RegistroRapido(),
                        SizedBox(height: 3),
                        Usuarios(),
                        SizedBox(height: 3),
                        Albergues(),
                        SizedBox(height: 3),
                        SitiosSeguros(),
                        SizedBox(height: 4),
                        ZonasRiesgo(),
                      ],
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
