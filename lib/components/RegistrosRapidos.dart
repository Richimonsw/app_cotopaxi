import 'package:app_cotopaxi/components/Albergues/RegistroAlbergueForm.dart';
import 'package:app_cotopaxi/components/SitioSeguros/RegistroSitioSeguroForm.dart';
import 'package:app_cotopaxi/components/Usuarios/RegistroUsuarioForm%20.dart';
import 'package:app_cotopaxi/components/ZonaRiesgo/RegistroZodaRiesgoForm.dart';
import 'package:app_cotopaxi/components/ZonasRiesgo.dart';
import 'package:app_cotopaxi/paginas/perfil.dart';
import 'package:flutter/material.dart';

class RegistroRapido extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(width: 8),
              Text(
                "Registro Rápido",
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
              children: [
                IntrinsicHeight(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistroUsuarioForm(),
                              ),
                            ).then((value) {
                              if (value == true) {
                                // Recargar la vista principal
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(),
                                  ),
                                );
                              }
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              'assets/icon/personasAdmin.png', // Asegúrate de que la extensión sea correcta
                                              width:
                                                  50, // Ajusta el tamaño según sea necesario
                                              height:
                                                  50, // Ajusta el tamaño según sea necesario
                                            ),
                                          )),

                                      SizedBox(
                                          height:
                                              5), // Espacio entre la imagen y el texto
                                      Text(
                                        "Usuario",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistroAlbergueForm(),
                              ),
                            ).then((value) {
                              if (value == true) {
                                // Recargar la vista principal
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(),
                                  ),
                                );
                              }
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              'assets/icon/albergue.png', // Asegúrate de que la extensión sea correcta
                                              width:
                                                  50, // Ajusta el tamaño según sea necesario
                                              height:
                                                  50, // Ajusta el tamaño según sea necesario
                                            ),
                                          )),

                                      SizedBox(
                                          height:
                                              5), // Espacio entre la imagen y el texto
                                      Text(
                                        "Albergue",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistroSitioSeguroForm(),
                              ),
                            ).then((value) {
                              if (value == true) {
                                // Recargar la vista principal
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(),
                                  ),
                                );
                              }
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                          padding: const EdgeInsets.all(10),
                                          child: Image.asset(
                                            'assets/icon/sitioSeguros.png', // Asegúrate de que la extensión sea correcta
                                            width:
                                                50, // Ajusta el tamaño según sea necesario
                                            height: 50,
                                            fit: BoxFit
                                                .contain, // Ajusta el tamaño según sea necesario
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: 80,
                                        child: Text(
                                          "Sitios seguros",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ) // Espacio entre la imagen y el texto
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistroZonaRiesgoForm(),
                              ),
                            ).then((value) {
                              if (value == true) {
                                // Recargar la vista principal
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(),
                                  ),
                                );
                              }
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              'assets/icon/zonaRiesgo.png', // Asegúrate de que la extensión sea correcta
                                              width:
                                                  50, // Ajusta el tamaño según sea necesario
                                              height: 50,
                                              fit: BoxFit
                                                  .contain, // Ajusta el tamaño según sea necesario
                                            ),
                                          )),
                                      SizedBox(height: 5),
                                      Container(
                                        width: 80,
                                        child: Text(
                                          "Zona de riesgo",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ) // Espacio entre la imagen y el texto
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
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
