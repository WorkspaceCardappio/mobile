import 'package:cardappio_mobile/core/theme.dart';
import 'package:cardappio_mobile/view/main_navigator.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const OrderApp());
}

class OrderApp extends StatelessWidget {
  const OrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardappio Profissional',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const MainNavigator(initialIndex: 2),
    );
  }
}