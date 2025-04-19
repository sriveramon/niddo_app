import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/amenity.dart';

class NewReservationScreen extends StatefulWidget {
  const NewReservationScreen({super.key});

  @override
  State<NewReservationScreen> createState() => _NewReservationScreenState();
}

class _NewReservationScreenState extends State<NewReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Amenity? selectedAmenity;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List<Amenity> amenities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAmenities();
  }

  static String get baseUrl {
    final url = dotenv.env['API_URL'];
    if (url == null) {
      throw Exception('API_URL not found in .env file');
    }
    return url;
  }

  Future<void> _fetchAmenities() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');

      if (token == null) {
        _logger.e('JWT token not found.');
        return;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String condoId = decodedToken['condo_id'];

      final url = Uri.parse('$baseUrl/amenities/amenitiesbycondo/$condoId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          amenities = data.map((json) => Amenity.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        _logger.e('Failed to load amenities: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching amenities: $e');
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _pickStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => startTime = time);
    }
  }

  Future<void> _pickEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => endTime = time);
    }
  }

  void _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      _logger.i('Amenity: ${selectedAmenity?.name}');
      _logger.i('Date: $selectedDate');
      _logger.i('Start Time: $startTime');
      _logger.i('End Time: $endTime');

      try {
        final token = await _secureStorage.read(key: 'jwt_token');
        if (token == null) {
          _logger.e('JWT token not found.');
          return;
        }

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String userId = decodedToken['user_id'];
        String amenityId = selectedAmenity!.id.toString();

        final payload = {
          'user_id': userId,
          'amenity_id': amenityId,
          'date': selectedDate?.toIso8601String().split('T')[0],
          'start_time':
              '${startTime?.hour.toString().padLeft(2, '0')}:${startTime?.minute.toString().padLeft(2, '0')}:00',
          'end_time':
              '${endTime?.hour.toString().padLeft(2, '0')}:${endTime?.minute.toString().padLeft(2, '0')}:00',
          'status': 'pending'
        };

        _logger.i('Payload: $payload');

        final url = Uri.parse('$baseUrl/reservations/');
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        );

        if (response.statusCode == 201) {
          _logger.i('Reservation successfully created.');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservation submitted. Please wait for approval.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          await Future.delayed(const Duration(seconds: 2));

          Navigator.pop(context, true); // ✅ Pass success back to MainScreen
        } else {
          _logger.e('Failed to create reservation: ${response.statusCode}');
        }
      } catch (e) {
        _logger.e('Error submitting reservation: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Reservation')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Amenity>(
                      decoration:
                          const InputDecoration(labelText: 'Select Amenity'),
                      items: amenities.map((amenity) {
                        return DropdownMenuItem(
                          value: amenity,
                          child: Text(amenity.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedAmenity = value),
                      validator: (value) =>
                          value == null ? 'Please select an amenity' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(selectedDate == null
                          ? 'Select Date'
                          : selectedDate!.toLocal().toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(startTime == null
                          ? 'Select Start Time'
                          : startTime!.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: _pickStartTime,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(endTime == null
                          ? 'Select End Time'
                          : endTime!.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: _pickEndTime,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitReservation,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
