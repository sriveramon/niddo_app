import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Niddo'),
      ),
      body: const Center(
        child: Text('Welcome to Niddo!'),
      ),
    );
  }
}
