import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserPayments(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawData = await _paymentService.getPayments(userId);
      _payments = rawData.map((e) => PaymentModel.fromJson(e)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
