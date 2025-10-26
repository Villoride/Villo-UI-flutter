import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  final bool isPickup;
  const MapPage({super.key, required this.isPickup});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng selectedLocation = const LatLng(19.0760, 72.8777); // Default Mumbai
  String selectedAddress = "Move the map to select location";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickup
            ? "Select Pickup Location"
            : "Select Drop Location"),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: selectedLocation, zoom: 15),
            onMapCreated: (controller) => _controller.complete(controller),
            onCameraMove: (position) {
              setState(() => selectedLocation = position.target);
            },
            onCameraIdle: () async {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                selectedLocation.latitude,
                selectedLocation.longitude,
              );
              setState(() {
                selectedAddress =
                "${placemarks.first.street}, ${placemarks.first.locality}";
              });
            },
          ),

          /// Pin in the center
          const Center(
            child: Icon(Icons.location_on,
                size: 45, color: Colors.redAccent),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, selectedAddress);
              },
              child: Text(
                "Confirm: $selectedAddress",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
