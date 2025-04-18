import 'package:flutter/material.dart';

class TodayReservationsWidget extends StatelessWidget {
  const TodayReservationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy reservation list
    List<String> reservations = [
      "Gym at 10:00 AM",
      "Pool at 2:00 PM",
    ];

    if (reservations.isEmpty) {
      return const Text("No reservations for today.");
    }

    return Column(
      children: reservations.map((r) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: const Icon(Icons.event_available),
            title: Text(r),
          ),
        );
      }).toList(),
    );
  }
}
