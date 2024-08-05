import 'package:app_cotopaxi/components/showCiudadanos.dart';
import 'package:flutter/material.dart';

class ListadoCiudadanos extends StatefulWidget {
  @override
  _CiudadanosScreenState createState() => _CiudadanosScreenState();
}

class _CiudadanosScreenState extends State<ListadoCiudadanos> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.group,
                    color: Color.fromRGBO(14, 54, 115, 1),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Listado de ciudadanos",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(14, 54, 115, 1),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ShowCiudadanos()),
                  );
                },
                child: Icon(
                  Icons.arrow_forward,
                  color: Color.fromRGBO(14, 54, 115, 1),
                  size: 24,
                ),
              ),
            ],
          ),
        ),
       
      ],
    );
  }
}

