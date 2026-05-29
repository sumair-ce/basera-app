import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/room_model.dart';
import '../viewmodels/booking_view_model.dart';
import '../core/constants/app_colors.dart';
import 'main_layout.dart';

class PaymentUploadView extends StatefulWidget {
  final RoomModel room;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final double totalAmount;
  final String guestName;
  final String guestPhone;
  final String guestCnic;
  final int guestCount;
  final String specialRequests;

  const PaymentUploadView({
    Key? key,
    required this.room,
    required this.startDate,
    required this.endDate,
    required this.userId,
    required this.totalAmount,
    required this.guestName,
    required this.guestPhone,
    required this.guestCnic,
    required this.guestCount,
    this.specialRequests = '',
  }) : super(key: key);

  @override
  _PaymentUploadViewState createState() => _PaymentUploadViewState();
}

class _PaymentUploadViewState extends State<PaymentUploadView> {
  File? _selectedImage;
  bool _submitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<String> _imageToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  void _submitPayment() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your payment screenshot first'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    final vm = Provider.of<BookingViewModel>(context, listen: false);

    // Step 1: Create booking
    final booking = await vm.bookRoom(
      room: widget.room,
      startDate: widget.startDate.toIso8601String(),
      endDate: widget.endDate.toIso8601String(),
      userId: widget.userId,
      totalPrice: widget.totalAmount,
    );

    if (booking == null) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMessage ?? 'Booking failed. Please try again.'),
              backgroundColor: AppColors.errorRed, behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }

    // Step 2: Upload payment screenshot
    final base64Screenshot = await _imageToBase64(_selectedImage!);
    bool paymentSuccess = await vm.uploadPaymentProof(
      booking.id,
      widget.userId,
      widget.totalAmount,
      base64Screenshot,
    );

    setState(() => _submitting = false);

    if (paymentSuccess && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Payment upload failed'),
            backgroundColor: AppColors.errorRed, behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking Submitted!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your booking and payment proof have been submitted successfully. Our team will verify and confirm within 2-3 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainLayout(userId: widget.userId, isGuest: false),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Back to Home', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int days = widget.endDate.difference(widget.startDate).inDays.clamp(1, 9999);

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildProgressBar(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hotel_rounded, color: AppColors.accentSand, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.room.title,
                          style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${DateFormat('MMM d').format(widget.startDate)} → ${DateFormat('MMM d, yyyy').format(widget.endDate)} · $days night${days > 1 ? 's' : ''}',
                    style: TextStyle(color: AppColors.pureWhite.withOpacity(0.85), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(color: AppColors.pureWhite, fontSize: 13)),
                      Text(
                        'Rs.${widget.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(color: AppColors.accentSand, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bank Details Card
            _buildSectionHeader(Icons.account_balance_rounded, 'Bank Transfer Details'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightGreen, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBankRow(Icons.account_balance_outlined, 'Bank', 'National Bank of Pakistan'),
                  const Divider(height: 20),
                  _buildBankRow(Icons.numbers_rounded, 'Account No.', '1234-5678-9012'),
                  const Divider(height: 20),
                  _buildBankRow(Icons.person_outline_rounded, 'Account Title', 'Basera Official'),
                  const Divider(height: 20),
                  _buildBankRow(Icons.currency_rupee_rounded, 'Amount to Transfer',
                      'Rs.${widget.totalAmount.toStringAsFixed(0)}'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Transfer exact amount and take a screenshot of the confirmation.',
                            style: TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Screenshot Upload
            _buildSectionHeader(Icons.upload_rounded, 'Upload Payment Screenshot'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: _selectedImage != null ? 220 : 130,
                decoration: BoxDecoration(
                  color: _selectedImage != null ? Colors.transparent : AppColors.lightGreen.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedImage != null ? AppColors.primaryGreen : AppColors.primaryGreen.withOpacity(0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryDark,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit_rounded, color: AppColors.pureWhite, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
                            child: const Icon(Icons.cloud_upload_rounded, color: AppColors.primaryGreen, size: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text('Tap to select screenshot', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 4),
                          const Text('JPG, PNG files accepted', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                        ],
                      ),
              ),
            ),

            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Screenshot selected: ${_selectedImage!.path.split('/').last.split('\\').last}',
                      style: const TextStyle(color: AppColors.primaryGreen, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: (_submitting || _selectedImage == null) ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedImage == null ? Colors.grey.shade300 : AppColors.primaryDark,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: _selectedImage == null ? 0 : 4,
                  shadowColor: AppColors.primaryDark.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _submitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.pureWhite, strokeWidth: 2),
                          SizedBox(width: 12),
                          Text('Submitting...', style: TextStyle(color: AppColors.pureWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedImage == null ? Icons.cloud_upload_outlined : Icons.lock_rounded,
                            color: _selectedImage == null ? Colors.grey : AppColors.pureWhite,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _selectedImage == null ? 'Upload Screenshot First' : 'Confirm & Submit Booking',
                            style: TextStyle(
                              color: _selectedImage == null ? Colors.grey : AppColors.pureWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          _buildStep(1, 'Hotel', true),
          _buildStepLine(true),
          _buildStep(2, 'Details', true),
          _buildStepLine(true),
          _buildStep(3, 'Payment', true),
        ],
      ),
    );
  }

  Widget _buildStep(int n, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? AppColors.accentSand : AppColors.pureWhite.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text('$n', style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.pureWhite.withOpacity(active ? 1.0 : 0.5), fontSize: 11)),
      ],
    );
  }

  Widget _buildStepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: active ? AppColors.accentSand : AppColors.pureWhite.withOpacity(0.3),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
      ],
    );
  }

  Widget _buildBankRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 18),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
