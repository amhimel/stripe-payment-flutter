import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_payment/core/key/stripe_key.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  double amountToCharge = 200.0; // Amount in USD
  String currency = 'USD';
  Map<String, dynamic>? intentPaymentData;

  void showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        if (kDebugMode) {
          debugPrint('Payment Successfully');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment is successful.'),
          ),
        );
        intentPaymentData = null;
      });
    } on StripeException catch (e) {
      if (kDebugMode) {
        debugPrint('Error from Stripe: ${e.error.localizedMessage}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Canceled'),
        ),
      );
    } catch (errorMsg, s) {
      if (kDebugMode) {
        debugPrint('Error: $s');
      }
      debugPrint('Error: $errorMsg');
    }
  }

  makeIntentForPayment(double amount, String currency) async {
    try {
      Map<String, dynamic> paymentInfo = {
        'amount': (amount * 100).toInt().toString(), // Convert to cents and then to string
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var responseFromStripeApi = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: paymentInfo,
        headers: {
          'Authorization': 'Bearer ${StripeKey.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      log('Response Body: ${responseFromStripeApi.body}');
      return jsonDecode(responseFromStripeApi.body);
    } catch (errorMsg, s) {
      if (kDebugMode) {
        debugPrint('Error: $s');
      }
      debugPrint('Error: $errorMsg');
    }
  }

  void paymentSheetInitialization(double amount, String currency) async {
    try {
      // Pass the double value directly, not converted to string
      intentPaymentData = await makeIntentForPayment(amount, currency);
      await Stripe.instance
          .initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret:
          intentPaymentData!['client_secret'], // from stripe
          style: ThemeMode.dark,
          merchantDisplayName: 'Himel',
          // customerId: intentPaymentData!['customer'], // from stripe
          // customerEphemeralKeySecret: intentPaymentData!['ephemeralKey'], // from stripe
        ),
      )
          .then((onValue) {
        log('Payment Sheet is ready $onValue');
      });
      showPaymentSheet();
    } catch (errorMsg, s) {
      if (kDebugMode) {
        debugPrint('Error: $s');
      }
      debugPrint('Error: $errorMsg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Pass the double value directly, not converted to string
            log('Payment of $amountToCharge $currency initiated.');
            paymentSheetInitialization(
              amountToCharge, // Pass as double
              currency,
            );
          },
          child: Text(
            "Make Payment ${amountToCharge.toStringAsFixed(2)} $currency",
          ),
        ),
      ),
    );
  }
}