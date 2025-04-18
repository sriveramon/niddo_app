import 'package:flutter/material.dart';
import '../widgets/dummy_news_widget.dart';
import '../widgets/today_reservations_widget.dart';
import '../widgets/today_visitors_widget.dart';
import '../widgets/section_divider.dart'; 
import '../screens/new_reservation_screen.dart';

class MainScreen extends StatelessWidget {
  final String userName;

  const MainScreen({super.key, required this.userName});

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(top: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Niddo"),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.deepOrange,
            height: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome $userName 👋', style: const TextStyle(fontSize: 24)),

            const SectionDivider(), // 🔸 Divider after welcome

            _sectionTitle("Latest News"),
            _sectionCard(child: const DummyNewsWidget()),

            const SectionDivider(), // 🔸 Divider between sections

            _sectionTitle("Today's Reservations"),
            _sectionCard(child: const TodayReservationsWidget()),

            const SectionDivider(), // 🔸 Divider between sections

            _sectionTitle("Today's Visitors"),
            _sectionCard(child: const TodayVisitorsWidget()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('New Reservation'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewReservationScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('New Visitor'),
                  onTap: () {
                    Navigator.pop(context);
                    // Add navigation to new visitor screen here
                  },
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
