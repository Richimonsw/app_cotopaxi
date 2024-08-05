import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCreateScreen extends StatefulWidget {
  final String bodegaId;

  ProductCreateScreen({Key? key, required this.bodegaId}) : super(key: key);

  @override
  _ProductCreateScreenState createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _stockMinController = TextEditingController();
  final TextEditingController _stockMaxController = TextEditingController();
  final TextEditingController _fechaVencimientoController = TextEditingController();

  bool _isLoading = false;

  Future<void> _createProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        if (token == null) {
          throw Exception('Token no encontrado');
        }

        final response = await http.post(
          Uri.parse('http://10.0.2.2:5000/api/productos/register'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'nombre': _nombreController.text,
            'codigo': _codigoController.text,
            'descripcion': _descripcionController.text,
            'stockMin': int.parse(_stockMinController.text),
            'stockMax': int.parse(_stockMaxController.text),
            'fechaVencimiento': _fechaVencimientoController.text,
            'bodega': widget.bodegaId,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto creado exitosamente')),
          );
          Navigator.of(context).pop(true); // Volver a la pantalla anterior
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Error al crear el producto');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Nuevo Producto'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _codigoController,
                decoration: InputDecoration(labelText: 'Código'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un código';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _stockMinController,
                decoration: InputDecoration(labelText: 'Stock Mínimo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el stock mínimo';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stockMaxController,
                decoration: InputDecoration(labelText: 'Stock Máximo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el stock máximo';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaVencimientoController,
                decoration: InputDecoration(labelText: 'Fecha de Vencimiento'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _fechaVencimientoController.text = pickedDate.toIso8601String().split('T')[0];
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _createProduct,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Crear Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}