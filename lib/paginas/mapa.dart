import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapScreen> {
  final String? baseURL = dotenv.env['BaseURL'];
  GoogleMapController? mapController;
  List<dynamic> albergues = [];
  List<dynamic> sitiosSeguros = [];
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool showEvacuationMessage = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      await _fetchDataFromServer();
    } else {
      await _fetchDataFromCache();
    }
  }

  Future<void> _fetchDataFromServer() async {
    try {

      final response = await http.get(
        Uri.parse(baseURL! + 'albergue/movil'),
      );
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          albergues = json.decode(response.body);
          _saveDataToCache('albergues', response.body);
        });
      } else {
        throw Exception('Failed to load albergues');
      }

      final response2 = await http.get(
        Uri.parse(baseURL! + 'sitioSeguro'),
      );
      print(response.body);
      if (response2.statusCode == 200) {
        setState(() {
          sitiosSeguros = json.decode(response2.body);
          _saveDataToCache('sitiosSeguros', response2.body);
        });
      } else {
        throw Exception('Failed to load sitios seguros');
      }

      _addMarkers();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _fetchDataFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String alberguesCache = prefs.getString('albergues') ?? '';
    if (alberguesCache.isNotEmpty) {
      setState(() {
        albergues = json.decode(alberguesCache);
      });
    }

    String sitiosSegurosCache = prefs.getString('sitiosSeguros') ?? '';
    if (sitiosSegurosCache.isNotEmpty) {
      setState(() {
        sitiosSeguros = json.decode(sitiosSegurosCache);
      });
    }

    _addMarkers();
  }

  Future<void> _saveDataToCache(String key, String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(-0.9339738, -78.6248696),
            zoom: 7.0,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          mapType: MapType.normal,
          markers: markers,
          polylines: polylines,
        ),
        Positioned(
          bottom: 125,
          right: 16,
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.blue),
                onPressed: _reloadMap,
                color: Colors.red, // Establece el color de fondo del botón
              ),
              Text(
                "Recargar",
                style: TextStyle(
                  color: Colors.black,
                  fontSize:
                      16, // Ajusta el tamaño de la fuente según sea necesario
                  fontWeight:
                      FontWeight.bold, // Opcional: Ajusta el peso de la fuente
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 70,
          right: 16,
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_forward, color: Colors.green),
                onPressed: _getUserLocation,
                color: Colors.red, // Establece el color de fondo del botón
              ),
              Text(
                "Trazar ruta",
                style: TextStyle(
                  color: Colors.black,
                  fontSize:
                      16, // Ajusta el tamaño de la fuente según sea necesario
                  fontWeight:
                      FontWeight.bold, // Opcional: Ajusta el peso de la fuente
                ),
              ),
            ],
          ),
        ),
        if (showEvacuationMessage)
          Positioned(
            bottom: 72,
            left: 16,
            right: 16,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(8),
            ),
          ),
      ],
    );
  }

  void _reloadMap() {
    setState(() {
      markers.clear();
      polylines.clear();
      _loadData();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();

      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16.0,
          ),
        ),
      );

      bool isConnected = await checkInternetConnection();
      if (isConnected) {
        _drawRoute(position);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String alberguesCache = prefs.getString('albergues') ?? '';
        String sitiosSegurosCache = prefs.getString('sitiosSeguros') ?? '';
        if (alberguesCache.isNotEmpty && sitiosSegurosCache.isNotEmpty) {
          setState(() {
            albergues = json.decode(alberguesCache);
            sitiosSeguros = json.decode(sitiosSegurosCache);
          });
          _addMarkers();
          _drawRouteOffline(position);
          _showEvacuationMessage();
        }
      }
    } catch (e) {
      print("Error getting user location: $e");
    }
  }

  void _showEvacuationMessage() {
    setState(() {
      showEvacuationMessage = true;
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        showEvacuationMessage = false;
      });
    });
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _drawRoute(Position userPosition) async {
    double shortestDistance = double.infinity;
    LatLng destination = LatLng(0, 0);
    for (dynamic albergue in albergues) {
      double lat = albergue['cordenadas_x'];
      double lng = albergue['cordenadas_y'];
      double distance = await Geolocator.distanceBetween(
          userPosition.latitude, userPosition.longitude, lat, lng);
      if (distance < shortestDistance) {
        shortestDistance = distance;
        destination = LatLng(lat, lng);
      }
    }
    for (dynamic sitio in sitiosSeguros) {
      double lat = sitio['cordenadas_x'];
      double lng = sitio['cordenadas_y'];
      double distance = await Geolocator.distanceBetween(
          userPosition.latitude, userPosition.longitude, lat, lng);
      if (distance < shortestDistance) {
        shortestDistance = distance;
        destination = LatLng(lat, lng);
      }
    }
    mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(destination, 30.0),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ruta de Evacuación Establecida"),
          content: Text("Presione 'Evacuar'"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _openGoogleMaps(userPosition, destination);
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text("Evacuar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openGoogleMaps(
      Position userPosition, LatLng destination) async {
    String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=${userPosition.latitude},${userPosition.longitude}&destination=${destination.latitude},${destination.longitude}';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'No se pudo abrir Google Maps';
    }
  }

  Future<void> _drawRouteOffline(Position userPosition) async {
    double shortestDistance = double.infinity;
    LatLng destination = LatLng(0, 0);
    for (dynamic albergue in albergues) {
      double lat = albergue['cordenadas_x'];
      double lng = albergue['cordenadas_y'];
      double distance = await Geolocator.distanceBetween(
          userPosition.latitude, userPosition.longitude, lat, lng);
      if (distance < shortestDistance) {
        shortestDistance = distance;
        destination = LatLng(lat, lng);
      }
    }
    for (dynamic sitio in sitiosSeguros) {
      double lat = sitio['cordenadas_x'];
      double lng = sitio['cordenadas_y'];
      double distance = await Geolocator.distanceBetween(
          userPosition.latitude, userPosition.longitude, lat, lng);
      if (distance < shortestDistance) {
        shortestDistance = distance;
        destination = LatLng(lat, lng);
      }
    }
    mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(destination, 30.0),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ruta Establecida  ¡Presione en el lugar asignado!"),
          content: Text("Posteriormente ¡Presione el icono de navegación!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  void _addMarkers() {
    Set<Marker> newMarkers = {};

    newMarkers.addAll(albergues.map((albergue) {
      double lat = albergue['cordenadas_x'];
      double lng = albergue['cordenadas_y'];
      String nombre = albergue['nombre'];

      return Marker(
        markerId: MarkerId('$lat-$lng'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: 'Albergue',
          snippet: nombre,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }));

    newMarkers.addAll(sitiosSeguros.map((sitio) {
      double lat = sitio['cordenadas_x'];
      double lng = sitio['cordenadas_y'];
      String nombre = sitio['nombre'];

      return Marker(
        markerId: MarkerId('$lat-$lng'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: 'Sitio Seguro',
          snippet: nombre,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }));

    setState(() {
      markers = newMarkers;
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: const Text('Map Example')),
      body: MapScreen(),
    ),
  ));
}
