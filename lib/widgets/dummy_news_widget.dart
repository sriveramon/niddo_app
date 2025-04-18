import 'package:flutter/material.dart';

class DummyNewsWidget extends StatelessWidget {
  const DummyNewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy news data
    List<String> newsList = [
      "New maintenance schedule for amenities.",
      "Upcoming event in the community this weekend.",
      "New features coming to Niddo soon!",
    ];

    return SingleChildScrollView(  // Wrap the column with SingleChildScrollView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // List of dummy news
          ...newsList.map((newsItem) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                newsItem,
                style: TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
