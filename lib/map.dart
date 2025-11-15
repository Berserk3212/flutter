import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Карта с кругом и маркером'),
        ),
        body: FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(55.7558, 37.6173),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: const LatLng(55.7558, 37.6173),
                  color: const Color(0x300000FF),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 3,
                  radius: 200, // Уменьшил радиус круга
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(55.7558, 37.6173),
                  width: 30,
                  height: 30,
                  child: const Icon(
                    Icons.circle,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}