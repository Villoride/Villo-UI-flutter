import 'package:flutter/material.dart';
import 'map_page.dart';

class RideBookingPage extends StatefulWidget {
  const RideBookingPage({super.key});

  @override
  State<RideBookingPage> createState() => _RideBookingPageState();
}

class _RideBookingPageState extends State<RideBookingPage> {
  String? pickupLocation;
  String? dropLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Villo Ride"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Pickup Location Section
            GestureDetector(
              onTap: () async {
                String? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapPage(isPickup: true),
                  ),
                );
                if (result != null) setState(() => pickupLocation = result);
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.my_location,
                        color: pickupLocation == null
                            ? Colors.grey
                            : Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pickupLocation ?? "Select Pickup Location",
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Drop Location Section
            GestureDetector(
              onTap: () async {
                String? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapPage(isPickup: false),
                  ),
                );
                if (result != null) setState(() => dropLocation = result);
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on,
                        color:
                        dropLocation == null ? Colors.grey : Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dropLocation ?? "Select Drop Location",
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            /// ✅ Confirm Button
            ElevatedButton(
              onPressed:
              (pickupLocation != null && dropLocation != null)
                  ? () {
                // TODO: Next - Route & Fare Calculation Page
              }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Confirm & Search Ride"),
            ),
          ],
        ),
      ),
    );
  }
}
