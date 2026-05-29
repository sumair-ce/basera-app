// This view is kept for backward compatibility.
// In the new flow, RoomListingView → HotelDetailView → BookingFormView → PaymentUploadView
// CheckoutView is no longer used but kept to prevent compilation errors.
import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../core/constants/app_colors.dart';
import 'booking_form_view.dart';

class CheckoutView extends StatelessWidget {
  final RoomModel room;
  final DateTime startDate;
  final DateTime endDate;

  const CheckoutView({
    Key? key,
    required this.room,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Immediately redirect to the new BookingFormView
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingFormView(
            room: room,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
      );
    });

    return const Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
    );
  }
}
