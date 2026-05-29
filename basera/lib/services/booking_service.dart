import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';

class BookingService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/bookings';

  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 201) {
      return BookingModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to create booking');
    }
  }

  Future<List<BookingModel>> getBookings(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl?userId=$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => BookingModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch bookings');
    }
  }

  Future<List<Map<String, dynamic>>> getBookedDatesForRoom(
    String roomId,
  ) async {
    final response = await http.get(Uri.parse('$baseUrl/room/$roomId/dates'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> applyDiscount(String code) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/discounts/apply'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid discount code');
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$bookingId/cancel'),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 200;
  }
}
