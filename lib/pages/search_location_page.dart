// lib/search_location_page.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class SearchLocationPage extends StatefulWidget {
  final LatLngHint? locationBias; // optional bias center (lat,lng)
  const SearchLocationPage({Key? key, this.locationBias}) : super(key: key);

  @override
  State<SearchLocationPage> createState() => _SearchLocationPageState();
}

class LatLngHint {
  final double lat;
  final double lng;
  LatLngHint(this.lat, this.lng);
}

class PlacePrediction {
  final String description;
  final String placeId;
  PlacePrediction(this.description, this.placeId);
}

class PlaceDetailsResult {
  final double lat;
  final double lng;
  final String address;
  PlaceDetailsResult(this.lat, this.lng, this.address);
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  final TextEditingController _ctrl = TextEditingController();
  Timer? _debounce;
  List<PlacePrediction> _predictions = [];
  bool _loading = false;

  void _onTextChanged(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (q.trim().isEmpty) {
        setState(() => _predictions = []);
        return;
      }
      _autocomplete(q.trim());
    });
  }

  Future<void> _autocomplete(String input) async {
    setState(() => _loading = true);
    final bias = widget.locationBias != null
        ? "&location=${widget.locationBias!.lat},${widget.locationBias!.lng}&radius=50000"
        : "";
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$kServerPlacesApiKey&types=geocode$bias";

    final res = await http.get(Uri.parse(url));
    setState(() => _loading = false);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data["status"] == "OK") {
        final preds = (data["predictions"] as List)
            .map((p) => PlacePrediction(p["description"], p["place_id"]))
            .toList();
        setState(() => _predictions = preds);
      } else {
        setState(() => _predictions = []);
      }
    } else {
      setState(() => _predictions = []);
    }
  }

  Future<PlaceDetailsResult?> _getPlaceDetail(String placeId) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=${Uri.encodeComponent(placeId)}&fields=formatted_address,geometry&key=$kServerPlacesApiKey";
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data["status"] == "OK" && data["result"] != null) {
        final resu = data["result"];
        final loc = resu["geometry"]["location"];
        final addr = resu["formatted_address"] ?? resu["name"] ?? "";
        return PlaceDetailsResult(loc["lat"] * 1.0, loc["lng"] * 1.0, addr);
      }
    }
    return null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search location"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _ctrl,
              onChanged: _onTextChanged,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Type place or address",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                  _ctrl.clear();
                  setState(() => _predictions = []);
                })
                    : null,
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, i) {
                final p = _predictions[i];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(p.description),
                  onTap: () async {
                    final details = await _getPlaceDetail(p.placeId);
                    if (details != null) {
                      Navigator.pop(context, details);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to get place details")));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
