import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF8dea88)),
      debugShowCheckedModeBanner: false,
      home: const LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

const double zoomLevel = 9.5;
const double scrollWheelSpeed = 0.001;

class _LocationScreenState extends State<LocationScreen> {
  LatLng currentLocation = LatLng(0.0, 0.0);
  late final MapController _mapController;

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.best));
      currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(currentLocation, zoomLevel);
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getCurrentLocation();
    });
  }

  @override
  dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await getCurrentLocation(),
        child: Icon(Icons.location_on, color: Colors.white),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: currentLocation,
          onPositionChanged: (position, hasGesture) {
            if (hasGesture) {
              setState(() {
                currentLocation = position.center;
              });
            }
          },
          onTap: (tapPosition, point) => setState(() {
            currentLocation = point;
          }),
          interactionOptions: InteractionOptions(
            scrollWheelVelocity: scrollWheelSpeed,
            doubleTapZoomCurve: Curves.bounceIn,
            doubleTapZoomDuration: Duration(milliseconds: 300),
            keyboardOptions: KeyboardOptions(),
          ),
          initialZoom: zoomLevel,
          maxZoom: 16,
          minZoom: zoomLevel,
        ),
        mapController: _mapController,

        children: [
          TileLayer(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"),
          MarkerLayer(
            rotate: true,
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: currentLocation,
                child: Icon(Icons.location_on, size: 48.0, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
