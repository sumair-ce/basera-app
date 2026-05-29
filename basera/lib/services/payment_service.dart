import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/payments';

  Future<void> submitPaymentProof(
    String bookingId,
    String userId,
    double amount,
    String screenshotBase64,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bookingId': bookingId,
        'userId': userId,
        'amount': amount,
        'screenshotUrl':
            screenshotBase64, // Using base64 string for simplicity instead of file upload
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to submit payment');
    }
  }

  Future<List<dynamic>> getPayments(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl?userId=$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch payments');
    }
  }
}
