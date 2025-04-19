import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class NewVisitorScreen extends StatefulWidget {
  const NewVisitorScreen({super.key});

  @override
  State<NewVisitorScreen> createState() => _NewVisitorScreenState();
}

class _NewVisitorScreenState extends State<NewVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? visitName;
  String? visitIdentification;
  String? plate;
  String? unitNumber;
  DateTime? visitDate;
  String status = 'pending'; // Default status for new visitor

  bool isLoading = false;

  static String get baseUrl {
    final url = dotenv.env['API_URL'];
    if (url == null) {
      throw Exception('API_URL not found in .env file');
    }
    return url;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => visitDate = date);
    }
  }

  void _submitVisitor() async {
    if (_formKey.currentState!.validate()) {
      _logger.i('Visit Name: $visitName');
      _logger.i('Visit Identification: $visitIdentification');
      _logger.i('Plate: $plate');
      _logger.i('Unit Number: $unitNumber');
      _logger.i('Visit Date: $visitDate');
      _logger.i('Status: $status');

      try {
        final token = await _secureStorage.read(key: 'jwt_token');
        if (token == null) {
          _logger.e('JWT token not found.');
          return;
        }

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String condoId = decodedToken['condo_id'];
        String userId = decodedToken['user_id'];

        final payload = {
          'user_id': userId,
          'condo_id': condoId,
          'identification': visitIdentification, // Optional
          'visit_name': visitName,
          'plate': plate, // Optional
          'unit_number': unitNumber,
          'visit_date': visitDate?.toIso8601String().split('T')[0],
          'status': status
        };

        _logger.i('Payload: $payload');

        final url = Uri.parse('$baseUrl/visitors/');
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        );

        if (response.statusCode == 201) {
          _logger.i('Visitor successfully created.');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visitor submitted successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          await Future.delayed(const Duration(seconds: 2));

          Navigator.pop(context, true); // ✅ Pass success back to previous screen
        } else {
          _logger.e('Failed to create visitor: ${response.statusCode}');
        }
      } catch (e) {
        _logger.e('Error submitting visitor: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Visitor')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Visitor Identification (Optional)'),
                      onChanged: (value) => setState(() => visitIdentification = value),
                      // No validation for the optional field
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Visitor Name'),
                      onChanged: (value) => setState(() => visitName = value),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter the visitor\'s name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Plate Number (Optional)'),
                      onChanged: (value) => setState(() => plate = value),
                      // No validation for the optional field
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Unit Number'),
                      onChanged: (value) => setState(() => unitNumber = value),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter the unit number' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(visitDate == null
                          ? 'Select Visit Date'
                          : visitDate!.toLocal().toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitVisitor,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
