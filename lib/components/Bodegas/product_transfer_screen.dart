import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductTransferScreen extends StatefulWidget {
  final String bodegaOrigenId;
  final List<dynamic> productos;

  ProductTransferScreen({Key? key, required this.bodegaOrigenId, required this.productos}) : super(key: key);

  @override
  _ProductTransferScreenState createState() => _ProductTransferScreenState();
}

class _ProductTransferScreenState extends State<ProductTransferScreen> {
  final String? baseURL = dotenv.env['BaseURL'];
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> productosATransferir = [];
  String? bodegaDestinoId;
  List<Map<String, dynamic>> bodegas = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchBodegas();
  }

  Future<void> _fetchBodegas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token no encontrado');
      }

      final response = await http.get(
        Uri.parse(baseURL! + 'bodega'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> bodegasData = json.decode(response.body);
        setState(() {
          bodegas = bodegasData
              .where((bodega) => bodega['_id'] != widget.bodegaOrigenId)
              .map((bodega) => {
                    '_id': bodega['_id'],
                    'nombre': bodega['nombre'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load bodegas');
      }
    } catch (e) {
      print('Error fetching bodegas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar bodegas')),
      );
    }
  }

  void _addProducto() {
    setState(() {
      productosATransferir.add({
        'producto': null,
        'cantidad': '',
      });
    });
  }

  void _removeProducto(int index) {
    setState(() {
      productosATransferir.removeAt(index);
    });
  }

  Future<void> _transferirProductos() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        error = null;
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        if (token == null) {
          throw Exception('Token no encontrado');
        }

        final response = await http.post(
          Uri.parse(baseURL! + 'productos/transferirProducto'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'bodegaOrigenId': widget.bodegaOrigenId,
            'bodegaDestinoId': bodegaDestinoId,
            'productos': productosATransferir,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Productos transferidos con éxito')),
          );
          Navigator.of(context).pop(true);
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Error al transferir productos');
        }
      } catch (e) {
        setState(() {
          error = e.toString();
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transferir Productos'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: bodegaDestinoId,
                decoration: InputDecoration(labelText: 'Bodega Destino'),
                items: bodegas.map((bodega) {
                  return DropdownMenuItem<String>(
                    value: bodega['_id'],
                    child: Text(bodega['nombre']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    bodegaDestinoId = value;
                  });
                },
                validator: (value) => value == null ? 'Por favor seleccione una bodega destino' : null,
              ),
              SizedBox(height: 20),
              ...productosATransferir.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> productoTransferir = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: productoTransferir['producto'],
                        decoration: InputDecoration(labelText: 'Producto'),
                        items: widget.productos.map((producto) {
                          return DropdownMenuItem<String>(
                            value: producto['_id'],
                            child: Text(producto['nombre']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            productosATransferir[index]['producto'] = value;
                          });
                        },
                        validator: (value) => value == null ? 'Por favor seleccione un producto' : null,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Cantidad'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            productosATransferir[index]['cantidad'] = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una cantidad';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Por favor ingrese un número válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeProducto(index),
                    ),
                  ],
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProducto,
                child: Text('Agregar Producto'),
              ),
              SizedBox(height: 20),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: isLoading ? null : _transferirProductos,
                child: isLoading ? CircularProgressIndicator() : Text('Transferir Productos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}