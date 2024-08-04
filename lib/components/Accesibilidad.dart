import 'package:app_cotopaxi/components/ScanQr.dart';
import 'package:flutter/material.dart';

class Accesibilidad extends StatelessWidget {
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
                "Vinculacion",
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scanqr(),
                              ),
                            );
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
                                              'assets/icon/setting.png', // Asegúrate de que la extensión sea correcta
                                              width:
                                                  80, // Ajusta el tamaño según sea necesario
                                              height:
                                                  80, // Ajusta el tamaño según sea necesario
                                            ),
                                          )),
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
