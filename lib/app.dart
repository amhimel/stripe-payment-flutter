import 'package:flutter/material.dart';
import 'package:stripe_payment/payment_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: PaymentScreen()
      ),

    );
  }
}
