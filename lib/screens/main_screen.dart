import 'package:flutter/material.dart';
import '../widgets/dummy_news_widget.dart';
import '../widgets/today_reservations_widget.dart';
import '../widgets/today_visitors_widget.dart';
import '../widgets/section_divider.dart';
import '../screens/new_reservation_screen.dart';
import '../screens/new_visitor_screen.dart';
import '../generated/l10n.dart'; // Import the generated localization file
class MainScreen extends StatefulWidget {
  final String userName;

  const MainScreen({super.key, required this.userName});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<TodayReservationsWidgetState> _todayReservationsKey = GlobalKey();
  final GlobalKey<TodayVisitorsWidgetState> _todayVisitsKey = GlobalKey();

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
        title: Text(S.of(context).appTitle),
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
            Text(
              S.of(context).welcomeMessage(widget.userName),  // Call the function with the userName
              style: const TextStyle(fontSize: 24),
            ),
            const SectionDivider(),
            _sectionTitle(S.of(context).latestNewsTitle),
            _sectionCard(child: const DummyNewsWidget()),
            const SectionDivider(),
            _sectionTitle(S.of(context).todaysReservationsTitle),
            _sectionCard(child: TodayReservationsWidget(key: _todayReservationsKey)),
            const SectionDivider(),
            _sectionTitle(S.of(context).todaysVisitorsTitle),
            _sectionCard(child: TodayVisitorsWidget(key: _todayVisitsKey)),
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
                  title: Text(S.of(context).newReservation),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewReservationScreen(),
                      ),
                    );

                    if (result == true) {
                      _todayReservationsKey.currentState?.refresh();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: Text(S.of(context).newVisitor),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewVisitorScreen(),
                      ),
                    );

                    if (result == true) {
                      _todayVisitsKey.currentState?.refresh();
                    }
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
