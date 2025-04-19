import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart'; // Import the generated localization file

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
      // Add localizationsDelegates and supportedLocales
      localizationsDelegates: [
        S.delegate,  // Use the generated localization delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
      ],
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
  void initState() {
    super.initState();
    
    // Set default email and password
    emailController.text = 'test@test.com'; // Default email
    passwordController.text = 'SRm011290'; // Default password
  }

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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(S.of(context).logging_in, style: const TextStyle(fontSize: 16)),
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
                      decoration: InputDecoration(labelText: S.of(context).email), // Use localized string
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: S.of(context).password), // Use localized string
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
                            child: Text(
                              S.of(context).login,  // Use localized string
                              style: const TextStyle(fontSize: 18, color: Colors.white),
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
