import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_payment/core/key/stripe_key.dart';
import 'app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = StripeKey.publishableKey;
  await Stripe.instance.applySettings();
  runApp(const App());
}

