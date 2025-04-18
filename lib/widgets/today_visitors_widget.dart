import 'package:flutter/material.dart';

class TodayVisitorsWidget extends StatelessWidget {
  const TodayVisitorsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy visitor list
    List<String> visitors = [
      "John Doe - 3:00 PM",
      "María López - 5:30 PM",
    ];

    if (visitors.isEmpty) {
      return const Text("No visitors scheduled for today.");
    }

    return Column(
      children: visitors.map((v) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(v),
          ),
        );
      }).toList(),
    );
  }
}
