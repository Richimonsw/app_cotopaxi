import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bodegas extends StatefulWidget {
  final String albergueId;

  Bodegas({required this.albergueId});

  @override
  _BodegasState createState() => _BodegasState();
}

class _BodegasState extends State<Bodegas> {
  List<dynamic> bodegas = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchBodegas();
  }

  Future<void> fetchBodegas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      } // Implementa esta función según tu lógica de almacenamiento
      final response = await http.get(
        Uri.parse(
            'https://f18c-201-183-161-189.ngrok-free.app/api/bodega/${widget.albergueId}/bodegas'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          bodegas = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load bodegas');
      }
    } catch (e) {
      setState(() {
        error = 'Error al obtener bodegas';
        isLoading = false;
      });
    }
  }

  void handleInspect(String id) {
    // Implementa la navegación según tu estructura de rutas
    // Por ejemplo:
    // Navigator.pushNamed(context, '/menu/Productos', arguments: {'Bodega_id': id});
  }

  Color getAlertColor(String? alerta) {
    if (alerta == "Crítico: La bodega está casi llena") return Colors.red;
    if (alerta == "Advertencia: La bodega está llegando a su capacidad máxima")
      return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bodegas'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : _buildContent(),
    );
  }

  @override
  Widget _buildContent() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Bodegas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Aquí iría el widget NotificacionGlobal si lo tienes
        // SliverToBoxAdapter(child: NotificacionGlobal(bodegas: bodegas)),
        bodegas.isEmpty
            ? SliverFillRemaining(child: _buildNoBodegas())
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildBodegaItem(bodegas[index]),
                  childCount: bodegas.length,
                ),
              ),
      ],
    );
  }

  Widget _buildNoBodegas() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.exclamationCircle,
                color: Colors.yellow[700], size: 48),
            SizedBox(height: 8),
            Text(
              'No hay ninguna bodega asignada al albergue todavía.',
              style: TextStyle(color: Colors.yellow[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodegaItem(dynamic bodega) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bodega['nombre'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildInfoRow(FontAwesomeIcons.warehouse,
                'Categoria: ${bodega['categoria']}', Colors.green),
            _buildInfoRow(FontAwesomeIcons.userTie,
                'Capacidad: ${bodega['capacidad']}', Colors.purple),
            _buildInfoRow(FontAwesomeIcons.box,
                'Productos: ${bodega['cantidadProductos']}', Colors.blue),
            _buildInfoRow(
              bodega['alerta'] != null
                  ? FontAwesomeIcons.exclamationCircle
                  : FontAwesomeIcons.checkCircle,
              bodega['alerta'] ?? 'Bodega estable',
              getAlertColor(bodega['alerta']),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => handleInspect(bodega['_id']),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.box, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Inspeccionar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
