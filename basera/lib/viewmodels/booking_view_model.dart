import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = false;
  String? _errorMessage;
  double _discountAmount = 0.0;
  List<BookingModel> _userBookings = [];
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BookingModel> get userBookings => _userBookings;

  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _userBookings = await _bookingService.getBookings(userId);
    } catch(e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BookingModel?> bookRoom({
    required RoomModel room,
    required String startDate,
    required String endDate,
    required String userId,
    required double totalPrice,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      double finalPrice = totalPrice - _discountAmount;
      final booking = await _bookingService.createBooking({
        'roomId': room.id,
        'userId': userId,
        'startDate': startDate,
        'endDate': endDate,
        'totalPrice': finalPrice > 0 ? finalPrice : 0,
      });
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> verifyDiscount(String code, double total) async {
    try {
      final res = await _bookingService.applyDiscount(code);
      if (res['type'] == 'percentage') {
        _discountAmount = total * (res['value'] / 100);
      } else {
        _discountAmount = res['value'].toDouble();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Invalid discount code';
      notifyListeners();
      return false;
    }
  }

  double get discountAmount => _discountAmount;

  Future<bool> uploadPaymentProof(String bookingId, String userId, double amount, String base64) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _paymentService.submitPaymentProof(bookingId, userId, amount, base64);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      return await _bookingService.cancelBooking(bookingId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
