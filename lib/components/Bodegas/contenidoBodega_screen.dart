import 'package:app_cotopaxi/components/Bodegas/product_create_screen.dart';
import 'package:app_cotopaxi/components/Bodegas/product_transfer_screen.dart';
import 'package:app_cotopaxi/components/Bodegas/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContenidoBodegaScreen extends StatefulWidget {
  final Map<String, dynamic> bodega;

  ContenidoBodegaScreen({Key? key, required this.bodega}) : super(key: key);

  @override
  _ContenidoScreenState createState() => _ContenidoScreenState();
}

class _ContenidoScreenState extends State<ContenidoBodegaScreen> {
  List<dynamic> productos = [];
  bool isLoading = false;
  String searchText = '';
  bool isQRModalVisible = false;
  bool isScanning = true;

  void _openQRScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(bodegaId: widget.bodega['_id']),
      ),
    ).then((_) => _fetchProductos()); // Actualiza los productos después de escanear
  }

  void _openCreateProductScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductCreateScreen(bodegaId: widget.bodega['_id']),
      ),
    ).then((value) {
      if (value == true) {
        // Si el producto fue creado exitosamente, actualiza la lista de productos
        _fetchProductos();
      }
    });
  }


  void _openTransferProductScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductTransferScreen(
          bodegaOrigenId: widget.bodega['_id'],
          productos: productos,
        ),
      ),
    ).then((value) {
      if (value == true) {
        // Si los productos fueron transferidos exitosamente, actualiza la lista de productos
        _fetchProductos();
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _fetchProductos();
  }

  Future<void> _fetchProductos() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se encontró el token de autenticación');
      }

      final bodegaId = widget.bodega['_id']?.toString();
      if (bodegaId == null) {
        throw Exception('Bodega ID is null');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/productos/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final productosFiltrados =
            data.where((producto) => producto['bodega'] == bodegaId).toList();

        setState(() {
          productos = productosFiltrados;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load productos');
      }
    } catch (e) {
      print('Error fetching productos: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bodega['nombre']?.toString() ?? 'Bodega'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQRScannerButton(),
              SizedBox(height: 20),
              Text(
                'Productos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                    onPressed: _openCreateProductScreen,
                    child: Text('Crear Producto'),
                  ),
              ElevatedButton(
                    onPressed: _openTransferProductScreen,
                    child: Text('Transferir Productos'),
                  ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre',
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
              SizedBox(height: 20),
              isLoading ? CircularProgressIndicator() : _buildProductosTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRScannerButton() {
    return Container(
      width: double.infinity,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).primaryColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: _openQRScanner,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
                SizedBox(width: 10),
                Text(
                  'Escanear Código QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductosTable() {
    final filteredProductos = productos
        .where((producto) =>
            producto['nombre']
                ?.toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()) ??
            false)
        .toList();

    final columns = [
      {'title': 'Nombre', 'dataIndex': 'nombre'},
      {'title': 'Stock Minimo', 'dataIndex': 'stockMin'},
      {'title': 'Stock Máximo', 'dataIndex': 'stockMax'},
      {'title': 'Codigo', 'dataIndex': 'codigo'},
      {'title': 'Descripción', 'dataIndex': 'descripcion'},
      {'title': 'Fecha de caducidad', 'dataIndex': 'fechaVencimiento'},
      {'title': 'Acciones', 'dataIndex': 'acciones'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map((column) => DataColumn(
                  label: Text(column['title']!),
                ))
            .toList(),
        rows: filteredProductos.map((producto) {
          return DataRow(
            cells: columns.map((column) {
              final value = producto[column['dataIndex']]?.toString() ?? 'N/A';
              if (column['dataIndex'] == 'acciones') {
                return DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => handleEdit(producto),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => handleDelete(producto),
                      ),
                    ],
                  ),
                );
              } else {
                return DataCell(Text(value));
              }
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

void handleEdit(Map<String, dynamic> ciudadano) {
  // Implementa la lógica de edición aquí
}

void handleDelete(Map<String, dynamic> ciudadano) {
  // Implementa la lógica de eliminación aquí
}
