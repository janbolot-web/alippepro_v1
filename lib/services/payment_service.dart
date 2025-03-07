import 'package:alippepro_v1/features/payment/view/widgets/redicret_screen.dart';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  Future createToPayment({
    required BuildContext context,
    required String amount,
    required String description,
    required String paymentMethod,
    required String product,
    required String userId,
  }) async {
    try {
      const String successUrl = 'https://alippepro.ru'; // Ваш successUrl
      final response = await http.post(
        Uri.parse('${Constants.uri}/pay'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'amount': amount,
          'description': description,
          'successUrl': successUrl,
          'paymentMethod': paymentMethod,
          'userId': userId
        }),
      );
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      print(responseData);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final redirectUrl =
            responseData['data']?['response']?['pg_redirect_url']?[0];

        if (redirectUrl != null) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebView(
                initialUrl: redirectUrl,
                successUrl: successUrl,
              ),
            ),
          );
          if (result != null && result == true) {
            // Успешная оплата

            var paymentId =
                responseData['data']?['response']?['pg_payment_id']?[0];

            final response = await http.post(
              Uri.parse('${Constants.uri}/statusPayment'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode({
                "paymentId": paymentId,
                "userId": userId,
                "amount": amount,
                "product": product,
                "planPoint": 120,
                "quizPoint": 30,
              }),
            );
            if (response.statusCode == 200) {
              final responseData = jsonDecode(response.body);
              print('responseData $responseData');
              // Navigator.pop(context, true); // Возвращаемся с успехом
              return responseData;
            }
          } else {
            // Ошибка оплаты
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Ката'),
                content: const Text('Төлөм ишке ашкан жок.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          print('Redirect URL not found in the response.');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }
}
