import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TodayReservationsWidget extends StatefulWidget {
  const TodayReservationsWidget({super.key});

  @override
  TodayReservationsWidgetState createState() => TodayReservationsWidgetState();
}

class TodayReservationsWidgetState extends State<TodayReservationsWidget> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<Map<String, dynamic>> reservations = [];
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
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'canceled':
        return Icons.cancel_outlined;
      case 'rejected':
        return Icons.thumb_down_alt_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'canceled':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTodayReservations();
  }

  Future<void> refresh() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    await _fetchTodayReservations();
  }

  Future<void> _fetchTodayReservations() async {
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

      final url = Uri.parse('$baseUrl/reservations/reservationsbyuser/$userId');
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
          reservations = data
              .where((r) => r['date'] == today)
              .map((r) => r as Map<String, dynamic>)
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
      return const Text('Failed to load today\'s reservations.');
    }

    if (reservations.isEmpty) {
      return const Text("No reservations for today.");
    }

    return Column(
      children: reservations.map((r) {
        String time = r['start_time'].substring(0, 5);
        String status = r['status'];
        IconData statusIcon = _getStatusIcon(status);
        Color iconColor = _getStatusColor(status);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: const Icon(Icons.event_available, color: Colors.deepOrange),
            title: Text('${r['amenity_name']} at $time'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: iconColor),
                const SizedBox(width: 4),
                Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(color: iconColor),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
