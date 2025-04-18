import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Add this import

final FlutterSecureStorage _secureStorage = FlutterSecureStorage(); // Instance for secure storage

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const NiddoApp());
}

class NiddoApp extends StatelessWidget {
  const NiddoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Niddo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFFFDF9F4),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final gradientColors = [
    Colors.deepOrange.shade400,
    Colors.deepOrange.shade600,
  ];

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => isLoading = true);

    final token = await AuthService.login(
      emailController.text,
      passwordController.text,
    );
    if (token != null) {
      // Store the token securely
      await _secureStorage.write(key: 'jwt_token', value: token);
      
      // Decode the JWT and extract the username
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print(decodedToken); // Debugging line to check the decoded token
      String userName = decodedToken['user_name']; // Adjust field name if necessary

      // Navigate to MainScreen with the decoded username
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(userName: userName)),
      );
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48),
          child: isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Logging in...", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Center(
                      child: Column(
                        children: [
                          Image.asset('assets/logo_no_background.png', height: 150),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const Spacer(),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _handleLogin,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradientColors),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'Log In',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
        ),
      ),
    );
  }
}
