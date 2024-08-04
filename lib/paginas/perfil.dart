import 'dart:convert';
import 'dart:io';
import 'package:app_cotopaxi/components/Accesibilidad.dart';
import 'package:app_cotopaxi/components/Albergues.dart';
import 'package:app_cotopaxi/components/RegistrosRapidos.dart';
import 'package:app_cotopaxi/components/SitioSeguros.dart';
import 'package:app_cotopaxi/components/Usuarios.dart';
import 'package:app_cotopaxi/components/ZonasRiesgo.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'login.dart'; // Importa la página de inicio de sesión

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      _imagenPath = prefs.getString('profileImageUrl') ??
          _defaultProfileImageUrl; // Obtener la URL de la imagen
      _qrImagePath = prefs.getString('qrImagePath') ?? '';
      _cedula = prefs.getString('cedula') ?? '';
      _userRole = prefs.getString('rol') ?? '';
    });
  }

  // Función para exportar los datos en PDF
  void _exportToPDF() async {
    // Solicitar permisos de almacenamiento
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de almacenamiento no concedido.')),
      );
      return;
    }

    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    final PdfGraphics graphics = page.graphics;
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

    // Agregar texto al PDF
    graphics.drawString('Perfil de Usuario', font,
        bounds: Rect.fromLTWH(0, 0, 200, 30));

    graphics.drawString('Nombre: $_nombre', font,
        bounds: Rect.fromLTWH(0, 30, 200, 30));
    graphics.drawString('Apellido: $_apellido', font,
        bounds: Rect.fromLTWH(0, 60, 200, 30));
    graphics.drawString('Albergue: $_albergue', font,
        bounds: Rect.fromLTWH(0, 90, 200, 30));
    graphics.drawString('$_cedula', font,
        bounds: Rect.fromLTWH(0, 30, 200, 30));

    if (_imagenPath.isNotEmpty) {
      // Agregar imagen de perfil
      final PdfBitmap profileImage =
          PdfBitmap(await _getImageBytes(_imagenPath));
      graphics.drawImage(profileImage, Rect.fromLTWH(0, 130, 150, 150));
    }

    if (_qrImagePath.isNotEmpty) {
      // Agregar imagen QR
      final PdfBitmap qrImage = PdfBitmap(await _getImageBytes(_qrImagePath));
      graphics.drawImage(qrImage, Rect.fromLTWH(0, 300, 150, 150));
    }

    // Guardar el documento en un archivo
    final List<int> bytes = await document.save();
    document.dispose();

    // Obtener el directorio de descargas
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('No se pudo obtener el directorio de almacenamiento.')),
      );
      return;
    }
    final downloadsDirectory = Directory('${directory.path}/Download');
    if (!await downloadsDirectory.exists()) {
      await downloadsDirectory.create(recursive: true);
    }

    final File file = File('${downloadsDirectory.path}/perfil_usuario.pdf');
    await file.writeAsBytes(bytes);

    // Notificar al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil exportado como PDF en ${file.path}')),
    );
  }

  Future<Uint8List> _getImageBytes(String url) async {
    final response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  // Método para editar la foto de perfil
  Future<void> _editProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

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
                content:
                    Text('Error al actualizar la imagen en la base de datos.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen a Cloudinary.')),
        );
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
    String apiUrl =
        "https://sistema-cotopaxi-backend.onrender.com/api/updateProfileImage";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cedula = prefs.getString('cedula') ??
        ''; // Recuperar la cédula de SharedPreferences

    print(
        "Sending updateProfileImage request with cedula: $cedula and imgPerfil: $imageUrl");

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
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
                color: const Color.fromRGBO(14, 54, 115, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 0,
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
                                      // Acción para editar la foto de perfil
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
                                icon:
                                    Icon(Icons.camera_alt, color: Colors.black),
                                onPressed: () {
                                  // Acción para editar la foto de perfil
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
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_nombre $_apellido',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _cedula,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                  if (_userRole == "admin_zonal" ||
                                      _userRole == "admin_farmaceutico" ||
                                      _userRole == "admin_general")
                                    Text(
                                      _userRole,
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 250, 239, 239),
                                        fontSize: 14,
                                      ),
                                    ),
                                  if (_userRole != "admin_zonal" &&
                                      _userRole != "admin_farmaceutico" &&
                                      _userRole != "admin_general")
                                    Text(
                                      'Ciudadano',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 250, 239, 239),
                                        fontSize: 14,
                                      ),
                                    ),
                                ]),
                            VerticalDivider(
                              color: Colors.white,
                              thickness: 1,
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_userRole != "admin_general")
                                  Text(
                                    'ALBERGUE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                Text(
                                  _albergue,
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                        255, 250, 239, 239),
                                    fontSize: 14,
                                  ),
                                ),
                                if (_userRole == "admin_general")
                                  Image.asset(
                                    'assets/icon/setting.png', // Asegúrate de que la extensión sea correcta
                                    width:
                                        50, // Ajusta el tamaño según sea necesario
                                    height:
                                        50, // Ajusta el tamaño según sea necesario
                                  ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
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
                      ] else if (_userRole == "admin_general") ...[
                        SizedBox(height: 4),
                        RegistroRapido(),
                        SizedBox(height: 10),
                        Usuarios(),
                        SizedBox(height: 10),
                        Albergues(),
                        SizedBox(height: 20),
                        SitiosSeguros(),
                        SizedBox(height: 20),
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
