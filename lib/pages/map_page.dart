import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  final bool isPickup;
  const MapPage({super.key, required this.isPickup});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _currentLatLng = const LatLng(28.6139, 77.2090); // default India
  String _address = "Fetching current location...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      LatLng latLng = LatLng(position.latitude, position.longitude);

      _moveCamera(latLng);
      _getAddressFromLatLng(latLng);
    } catch (e) {
      setState(() {
        _address = "Unable to fetch location";
      });
    }
  }

  Future<void> _moveCamera(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16),
      ),
    );
    setState(() {
      _currentLatLng = target;
    });
  }

  Future<void> _getAddressFromLatLng(LatLng pos) async {
    List<Placemark> placemark =
    await placemarkFromCoordinates(pos.latitude, pos.longitude);

    if (placemark.isNotEmpty) {
      final p = placemark.first;
      setState(() {
        _address =
        "${p.street}, ${p.locality}, ${p.subAdministrativeArea}, ${p.postalCode}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: _currentLatLng, zoom: 14),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (controller) => _controller.complete(controller),
            onCameraMove: (position) {
              _currentLatLng = position.target;
            },
            onCameraIdle: () {
              _getAddressFromLatLng(_currentLatLng);
            },
          ),

          /// 📌 Center Map Pin
          const Center(
            child: Icon(
              Icons.location_on,
              size: 40,
              color: Colors.red,
            ),
          ),

          /// 📌 Address Box & Confirm Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(18),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_address,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _address);
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blueAccent),
                    child: Text(widget.isPickup
                        ? "Set Pickup Location"
                        : "Set Drop Location"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
