import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      title: 'Controle de Carga',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(authService: authService),
    );
  }
}
