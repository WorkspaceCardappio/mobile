import 'package:cardappio_mobile/core/app_config.dart';
import 'package:cardappio_mobile/core/auth_service.dart';
import 'package:cardappio_mobile/core/theme.dart';
import 'package:cardappio_mobile/view/main_navigator.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.initialize();

  final authService = AuthService();
  await authService.initialize();

  runApp(OrderApp(authService: authService));
}

class OrderApp extends StatelessWidget {
  final AuthService authService;

  const OrderApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardappio Profissional - ${AppConfig.environmentName}',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: MainNavigator(
        initialIndex: 2,
        authService: authService,
      ),
    );
  }
}