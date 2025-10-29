// lib/search_location_page.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class SearchLocationPage extends StatefulWidget {
  const SearchLocationPage({Key? key}) : super(key: key);

  @override
  State<SearchLocationPage> createState() => _SearchLocationPageState();
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
  bool _loading = false;
  List<PlacePrediction> _predictions = [];

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (text.trim().length < 3) {
        setState(() => _predictions = []);
        return;
      }
      _placeAutoComplete(text.trim());
    });
  }

  Future<void> _placeAutoComplete(String input) async {
    setState(() => _loading = true);

    final sessionToken = DateTime.now().millisecondsSinceEpoch.toString();

    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=${Uri.encodeComponent(input)}"
        "&key=$kServerPlacesApiKey"
        "&sessiontoken=$sessionToken";

    print("🔍 AUTOCOMPLETE URL: $url");

    final res = await http.get(Uri.parse(url));
    setState(() => _loading = false);

    final data = jsonDecode(res.body);
    print("📌 API Response: $data");

    if (data["status"] == "OK") {
      final list = (data["predictions"] as List)
          .map((p) => PlacePrediction(p["description"], p["place_id"]))
          .toList();
      setState(() => _predictions = list);
    } else {
      setState(() => _predictions = []);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("API Error: ${data["status"]}")));
    }
  }

  Future<PlaceDetailsResult?> _getDetails(String placeId) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&fields=formatted_address,geometry"
        "&key=$kServerPlacesApiKey";

    print("📍 DETAILS URL: $url");

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    print("📍 DETAILS Response: $data");

    if (data["status"] == "OK") {
      final r = data["result"];
      return PlaceDetailsResult(
        r["geometry"]["location"]["lat"],
        r["geometry"]["location"]["lng"],
        r["formatted_address"] ?? "",
      );
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
        title: const Text("Search Location"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                hintText: "Search a place...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _ctrl.clear();
                    setState(() => _predictions = []);
                  },
                )
                    : null,
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (_, i) {
                final p = _predictions[i];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(p.description),
                  onTap: () async {
                    final details = await _getDetails(p.placeId);
                    if (details != null) {
                      Navigator.pop(context, details);
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
