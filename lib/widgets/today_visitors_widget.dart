import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TodayVisitorsWidget extends StatefulWidget {
  const TodayVisitorsWidget({super.key});

  @override
  TodayVisitorsWidgetState createState() => TodayVisitorsWidgetState();
}

class TodayVisitorsWidgetState extends State<TodayVisitorsWidget> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<Map<String, dynamic>> visitors = [];
  bool isLoading = true;
  bool hasError = false;

  static String get baseUrl {
    final url = dotenv.env['API_URL'];
    if (url == null) {
      throw Exception('API_URL not found in .env file');
    }
    return url;
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top;
      case 'approved':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTodayVisitors();
  }

  Future<void> refresh() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    await _fetchTodayVisitors();
  }

  Future<void> _fetchTodayVisitors() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        return;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String userId = decodedToken['user_id'];

      final url = Uri.parse('$baseUrl/visitors/visitorsbyuser/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final today = DateTime.now().toIso8601String().split('T')[0];

        setState(() {
          visitors = data
              .where((v) => v['visit_date'] == today)
              .map((v) => v as Map<String, dynamic>)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return const Text('Failed to load today\'s visitors.');
    }

    if (visitors.isEmpty) {
      return const Text("No visitors scheduled for today.");
    }

    return Column(
      children: visitors.map((v) {
        String name = v['visit_name'];
        String time = v['visit_date']; // e.g., '2025-04-20'
        String status = v['status'];

        IconData statusIcon = _getStatusIcon(status);
        Color statusColor = _getStatusColor(status);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.deepOrange),
            title: Text(name),
            subtitle: Text('Visit date: $time'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(color: statusColor),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
