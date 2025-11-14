import 'package:cardappio_mobile/core/theme.dart';
import 'package:cardappio_mobile/view/main_navigator.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const OrderApp());
}

class OrderApp extends StatelessWidget {
  const OrderApp({super.key});
  static const String mainNavigatorRoute = '/main-nav';


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cardappio Profissional',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: mainNavigatorRoute,
      routes: {
        mainNavigatorRoute: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final initialIndex = args is int ? args : 2;

          return MainNavigator(initialIndex: initialIndex);
        },
      },
    );
  }
}