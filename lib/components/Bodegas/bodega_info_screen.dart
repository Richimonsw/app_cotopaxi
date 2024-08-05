import 'package:flutter/material.dart';

class BodegaInfoScreen extends StatelessWidget {
  final Map<String, dynamic> bodega;

  BodegaInfoScreen({Key? key, required this.bodega}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de la Bodega'),
        backgroundColor: Color.fromRGBO(14, 54, 115, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${bodega['nombre']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            InfoItem(
                icon: Icons.location_on,
                label: 'Categoria',
                value: bodega['categoria']?.toString() ?? 'N/A'),
            InfoItem(
                icon: Icons.location_on,
                label: 'Capacidad',
                value: bodega['capacidad']?.toString() ?? 'N/A'),
            InfoItem(
                icon: Icons.people,
                label: 'Cantidad de productos',
                value: bodega['cantidadProductos']?.toString() ?? 'N/A'),
            InfoItem(
                icon: Icons.store,
                label: 'Porcentaje de ocupación',
                value: bodega['porcentajeOcupacion']?.toString() ?? 'N/A'),
            InfoItem(
                icon: Icons.person,
                label: 'Alerta',
                value: bodega['alerta']?.toString() ?? 'Bodega estable'),
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
