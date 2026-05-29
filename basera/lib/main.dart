import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/login_view_model.dart';
import 'viewmodels/signup_view_model.dart';
import 'viewmodels/room_view_model.dart';
import 'viewmodels/booking_view_model.dart';
import 'viewmodels/payment_view_model.dart';
import 'views/login_view.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()),
        ChangeNotifierProvider(create: (_) => PaymentViewModel()),
      ],
      child: const HotelBookingApp(),
    ),
  );
}

class HotelBookingApp extends StatelessWidget {
  const HotelBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel & Guest House Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.backgroundBeige,
        fontFamily: 'Roboto',
      ),
      home: LoginView(),
    );
  }
}
