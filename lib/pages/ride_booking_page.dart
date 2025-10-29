// lib/ride_booking_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'constants.dart';
import 'search_location_page.dart';

class RideBookingPage extends StatefulWidget {
  const RideBookingPage({Key? key}) : super(key: key);

  @override
  State<RideBookingPage> createState() => _RideBookingPageState();
}

class _RideBookingPageState extends State<RideBookingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  LatLng? _pickupLatLng, _dropLatLng;
  String? _pickupAddress, _dropAddress;

  Set<Marker> _markers = {};
  List<LatLng> _polylineCoords = [];
  bool _searchingDriver = false;
  double? _distanceKm;
  String? _etaText;
  double? _fare;
  Timer? _driverTimer;
  Map<String, LatLng> _driverMarkers = {}; // id -> position

  static const double baseFare = 30; // INR
  static const double perKm = 12; // INR per km

  @override
  void initState() {
    super.initState();
    _setDefaultPickupToCurrent();
  }

  Future<void> _setDefaultPickupToCurrent() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final latLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _pickupLatLng = latLng;
        _pickupAddress = "Current location";
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        );
      });

      final controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<void> _openSearch(bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchLocationPage()),
    );

    if (result is PlaceDetailsResult) {
      setState(() {
        if (isPickup) {
          _pickupLatLng = LatLng(result.lat, result.lng);
          _pickupAddress = result.address;
          _markers.removeWhere((m) => m.markerId.value == 'pickup');
          _markers.add(
            Marker(
              markerId: const MarkerId('pickup'),
              position: _pickupLatLng!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
            ),
          );
        } else {
          _dropLatLng = LatLng(result.lat, result.lng);
          _dropAddress = result.address;
          _markers.removeWhere((m) => m.markerId.value == 'drop');
          _markers.add(
            Marker(
              markerId: const MarkerId('drop'),
              position: _dropLatLng!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          );
        }
      });

      if (_pickupLatLng != null && _dropLatLng != null) {
        await _drawRouteAndCalculate();
        _moveCameraToFit();
      } else {
        final c = await _controller.future;
        c.animateCamera(CameraUpdate.newLatLngZoom(
            isPickup ? _pickupLatLng! : _dropLatLng!, 15));
      }
    }
  }

  Future<void> _drawRouteAndCalculate() async {
    if (_pickupLatLng == null || _dropLatLng == null) return;

    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_pickupLatLng!.latitude},${_pickupLatLng!.longitude}&destination=${_dropLatLng!.latitude},${_dropLatLng!.longitude}&mode=driving&key=$kServerPlacesApiKey";

    final resp = await http.get(Uri.parse(url));
    final data = jsonDecode(resp.body);
    if ((data["routes"] as List).isEmpty) return;

    final route = data["routes"][0];
    final leg = route["legs"][0];
    final distanceValMeters = (leg["distance"]["value"] ?? 0) * 1.0;
    final durationText = leg["duration"]["text"] ?? "--";
    final overviewPolyline = route["overview_polyline"]["points"];

    final points = PolylinePoints().decodePolyline(overviewPolyline);
    _polylineCoords = points.map((p) => LatLng(p.latitude, p.longitude)).toList();

    _distanceKm = distanceValMeters / 1000.0;
    _etaText = durationText;
    _fare = baseFare + (_distanceKm! * perKm);

    setState(() {});
  }

  Future<void> _moveCameraToFit() async {
    if (_pickupLatLng == null || _dropLatLng == null) return;
    final swLat = min(_pickupLatLng!.latitude, _dropLatLng!.latitude);
    final swLng = min(_pickupLatLng!.longitude, _dropLatLng!.longitude);
    final neLat = max(_pickupLatLng!.latitude, _dropLatLng!.latitude);
    final neLng = max(_pickupLatLng!.longitude, _dropLatLng!.longitude);
    final bounds = LatLngBounds(
      southwest: LatLng(swLat, swLng),
      northeast: LatLng(neLat, neLng),
    );
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  void _startSimulateDrivers() {
    if (_pickupLatLng == null) return;
    _driverMarkers.clear();
    final rand = Random();
    for (int i = 0; i < 6; i++) {
      final dLat = _pickupLatLng!.latitude + (rand.nextDouble() - 0.5) / 500;
      final dLng = _pickupLatLng!.longitude + (rand.nextDouble() - 0.5) / 500;
      _driverMarkers["driver_$i"] = LatLng(dLat, dLng);
    }

    _driverTimer?.cancel();
    _driverTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final keys = _driverMarkers.keys.toList();
      for (var key in keys) {
        final cur = _driverMarkers[key]!;
        final next = LatLng(
          cur.latitude + (rand.nextDouble() - 0.5) / 2000,
          cur.longitude + (rand.nextDouble() - 0.5) / 2000,
        );
        _driverMarkers[key] = next;
      }
      setState(() {});
    });
  }

  Future<void> _confirmBooking() async {
    if (_pickupLatLng == null || _dropLatLng == null) return;

    setState(() => _searchingDriver = true);
    _startSimulateDrivers();

    await Future.delayed(const Duration(seconds: 4));

    String? assignedDriverId;
    double? bestDist;
    for (var e in _driverMarkers.entries) {
      final d = distanceBetween(
        _pickupLatLng!.latitude,
        _pickupLatLng!.longitude,
        e.value.latitude,
        e.value.longitude,
      );
      if (bestDist == null || d < bestDist) {
        bestDist = d;
        assignedDriverId = e.key;
      }
    }

    final booking = {
      "pickup": {
        "lat": _pickupLatLng!.latitude,
        "lng": _pickupLatLng!.longitude,
        "address": _pickupAddress
      },
      "drop": {
        "lat": _dropLatLng!.latitude,
        "lng": _dropLatLng!.longitude,
        "address": _dropAddress
      },
      "distance_km": _distanceKm,
      "eta": _etaText,
      "fare": _fare,
      "driverId": assignedDriverId,
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      final res = await http.post(
        Uri.parse("http://YOUR_BACKEND_SERVER/api/bookings"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(booking),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking confirmed!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Driver assigned (demo).")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking saved locally (demo).")),
      );
    } finally {
      setState(() => _searchingDriver = false);
    }
  }

  @override
  void dispose() {
    _driverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final driverMarkerSet = _driverMarkers.entries.map((e) {
      return Marker(
        markerId: MarkerId(e.key),
        position: e.value,
        icon:
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: "Driver ${e.key}"),
      );
    }).toSet();

    final polylines = <Polyline>{
      if (_polylineCoords.isNotEmpty)
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blueAccent,
          points: _polylineCoords,
          width: 5,
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Villo Ride"),
        backgroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickupLatLng ?? const LatLng(20.5937, 78.9629),
              zoom: 5,
            ),
            markers: _markers.union(driverMarkerSet),
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (c) => _controller.complete(c),
          ),
          Positioned(
            top: 14,
            left: 12,
            right: 12,
            child: Column(
              children: [
                _topCard(
                  icon: Icons.my_location,
                  title: _pickupAddress ?? "Pickup",
                  subtitle: _pickupLatLng == null ? "Not set" : "",
                  onTap: () => _openSearch(true),
                ),
                const SizedBox(height: 8),
                _topCard(
                  icon: Icons.place,
                  title: _dropAddress ?? "Drop",
                  subtitle: _dropLatLng == null ? "Tap to set drop" : "",
                  onTap: () => _openSearch(false),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 18,
            left: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _distanceKm != null
                                  ? "${_distanceKm!.toStringAsFixed(2)} km"
                                  : "---",
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(_etaText ?? "--"),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _fare != null
                                  ? "₹ ${_fare!.toStringAsFixed(0)}"
                                  : "--",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text("Est. fare",
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_pickupLatLng != null &&
                        _dropLatLng != null &&
                        !_searchingDriver)
                        ? _confirmBooking
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _searchingDriver
                        ? const Text("Searching driver...")
                        : const Text("Confirm & Book"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(subtitle,
                        style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

  double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // metres
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dphi = (lat2 - lat1) * pi / 180;
    final dlambda = (lon2 - lon1) * pi / 180;
    final a = sin(dphi / 2) * sin(dphi / 2) +
        cos(phi1) * cos(phi2) * sin(dlambda / 2) * sin(dlambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }
}
