import 'package:flutter/material.dart';

class BodegaInfoScreen extends StatelessWidget {
  final Map<String, dynamic> bodega;

  BodegaInfoScreen({Key? key, required this.bodega}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de la Bodega',
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
                '${bodega['nombre']}',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            SectionTitle(title: 'Detalles de la Bodega'),
            Center(
              child: Column(
                children: [
                  InfoCard(
                    icon: Icons.category,
                    label: 'Categoria',
                    value: bodega['categoria']?.toString() ?? 'N/A',
                  ),
                  InfoCard(
                    icon: Icons.production_quantity_limits,
                    label: 'Capacidad',
                    value: bodega['capacidad']?.toString() ?? 'N/A',
                  ),
                  InfoCard(
                    icon: Icons.amp_stories_outlined,
                    label: 'Cantidad de productos',
                    value: bodega['cantidadProductos']?.toString() ?? 'N/A',
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SectionTitle(title: 'Estado'),
            Center(
              child: Column(
                children: [
                  InfoCard(
                    icon: Icons.percent,
                    label: 'Porcentaje de ocupación',
                    value: bodega['porcentajeOcupacion']?.toString() ?? 'N/A',
                  ),
                  InfoCard(
                    icon: Icons.warning_amber_rounded,
                    label: 'Alerta',
                    value: bodega['alerta']?.toString() ?? 'Bodega estable',
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
