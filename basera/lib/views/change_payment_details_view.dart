import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ChangePaymentDetailsView extends StatefulWidget {
  const ChangePaymentDetailsView({super.key});

  @override
  State<ChangePaymentDetailsView> createState() => _ChangePaymentDetailsViewState();
}

class _ChangePaymentDetailsViewState extends State<ChangePaymentDetailsView> {
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details', style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
      ),
      backgroundColor: AppColors.backgroundBeige,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primaryGreen]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('Your Default Card', style: TextStyle(color: Colors.white70, fontSize: 14)),
                   const SizedBox(height: 10),
                   const Text('**** **** **** 1234', style: TextStyle(color: AppColors.pureWhite, fontSize: 22, letterSpacing: 2)),
                   const SizedBox(height: 20),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: const [
                       Text('JOHN DOE', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
                       Text('12/28', style: TextStyle(color: AppColors.pureWhite)),
                     ],
                   )
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField('Cardholder Name', _cardNameController),
            const SizedBox(height: 16),
            _buildTextField('Card Number', _cardNumberController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Expiry (MM/YY)', _expiryController)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('CVV', _cvvController)),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Details Updated!')));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentSand,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Update Card', style: TextStyle(color: AppColors.pureWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.pureWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
