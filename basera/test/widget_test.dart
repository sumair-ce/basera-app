// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:basera/main.dart';
import 'package:basera/viewmodels/login_view_model.dart';
import 'package:basera/viewmodels/signup_view_model.dart';
import 'package:basera/viewmodels/room_view_model.dart';
import 'package:basera/viewmodels/booking_view_model.dart';
import 'package:basera/viewmodels/payment_view_model.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
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

    // Verify that the app builds successfully.
    expect(find.byType(HotelBookingApp), findsOneWidget);
  });
}
