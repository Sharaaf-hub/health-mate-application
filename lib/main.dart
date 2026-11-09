
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/health_provider.dart';
import 'controllers/user_provider.dart';
import 'views/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const HealthMateApp());
}

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HealthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HealthMate',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F6EF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF234B3A),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
