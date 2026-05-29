import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/room_model.dart';
import '../viewmodels/login_view_model.dart';
import '../viewmodels/booking_view_model.dart';
import 'payment_upload_view.dart';

class BookingFormView extends StatefulWidget {
  final RoomModel room;
  final DateTime startDate;
  final DateTime endDate;

  const BookingFormView({
    Key? key,
    required this.room,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  _BookingFormViewState createState() => _BookingFormViewState();
}

class _BookingFormViewState extends State<BookingFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController(text: '1');
  final TextEditingController _requestsController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  late int _days;
  late double _baseTotal;
  bool _discountApplied = false;

  @override
  void initState() {
    super.initState();
    _days = widget.endDate.difference(widget.startDate).inDays;
    if (_days == 0) _days = 1;
    _baseTotal = widget.room.pricePerNight * _days;
    // Pre-fill name from logged-in user
    final user = Provider.of<LoginViewModel>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _guestsController.dispose();
    _requestsController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _applyDiscount() async {
    if (_discountController.text.isEmpty) return;
    final vm = Provider.of<BookingViewModel>(context, listen: false);
    bool success = await vm.verifyDiscount(_discountController.text, _baseTotal);
    if (success) {
      setState(() => _discountApplied = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Discount applied! ✓'), backgroundColor: AppColors.primaryGreen, behavior: SnackBarBehavior.floating),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMessage ?? 'Invalid code'), backgroundColor: AppColors.errorRed, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _proceed() {
    if (!_formKey.currentState!.validate()) return;

    final bvm = Provider.of<BookingViewModel>(context, listen: false);
    final loginVm = Provider.of<LoginViewModel>(context, listen: false);
    double finalTotal = _baseTotal - bvm.discountAmount;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentUploadView(
          room: widget.room,
          startDate: widget.startDate,
          endDate: widget.endDate,
          userId: loginVm.currentUser?.id ?? '',
          totalAmount: finalTotal,
          guestName: _nameController.text.trim(),
          guestPhone: _phoneController.text.trim(),
          guestCnic: _cnicController.text.trim(),
          guestCount: int.tryParse(_guestsController.text) ?? 1,
          specialRequests: _requestsController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<BookingViewModel>(context);
    double finalTotal = _baseTotal - vm.discountAmount;

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Guest Details', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            _buildProgressBar(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking summary card
                    _buildSummaryCard(),
                    const SizedBox(height: 24),

                    // Guest Info Section
                    _buildSectionHeader(Icons.person_rounded, 'Guest Information'),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _cnicController,
                      label: 'CNIC (e.g. 35202-1234567-1)',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'CNIC is required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty) ? 'Phone is required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _guestsController,
                      label: 'Number of Guests',
                      icon: Icons.group_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return 'Enter valid guest count';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _requestsController,
                      label: 'Special Requests (Optional)',
                      icon: Icons.comment_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Discount Section
                    _buildSectionHeader(Icons.local_offer_outlined, 'Discount Code'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            decoration: InputDecoration(
                              hintText: 'Enter discount code',
                              filled: true,
                              fillColor: AppColors.pureWhite,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _discountApplied ? null : _applyDiscount,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: _discountApplied ? AppColors.primaryGreen : AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              _discountApplied ? 'Applied ✓' : 'Apply',
                              style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Price Breakdown
                    _buildSectionHeader(Icons.receipt_outlined, 'Price Breakdown'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow('Rs.${widget.room.pricePerNight.toStringAsFixed(0)} × $_days night${_days > 1 ? 's' : ''}',
                              'Rs.${_baseTotal.toStringAsFixed(0)}', false),
                          if (_discountApplied)
                            _buildPriceRow('Discount', '- Rs.${vm.discountAmount.toStringAsFixed(0)}', true, isDiscount: true),
                          const Divider(height: 24),
                          _buildPriceRow('Total Amount', 'Rs.${finalTotal.toStringAsFixed(0)}', true, isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Proceed Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              color: AppColors.pureWhite,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: vm.isLoading ? null : _proceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentSand,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: vm.isLoading
                      ? const CircularProgressIndicator(color: AppColors.pureWhite)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Proceed to Payment', style: TextStyle(color: AppColors.pureWhite, fontSize: 17, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: AppColors.pureWhite),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          _buildStep(1, 'Hotel', true),
          _buildStepLine(true),
          _buildStep(2, 'Details', true),
          _buildStepLine(false),
          _buildStep(3, 'Payment', false),
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.room.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: AppColors.primaryGreen,
                child: const Icon(Icons.hotel, color: AppColors.pureWhite),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.room.title,
                    style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM d').format(widget.startDate)} → ${DateFormat('MMM d, yyyy').format(widget.endDate)}',
                  style: TextStyle(color: AppColors.pureWhite.withOpacity(0.85), fontSize: 13),
                ),
                Text(
                  '$_days night${_days > 1 ? 's' : ''} · ${widget.room.city}',
                  style: TextStyle(color: AppColors.pureWhite.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        filled: true,
        fillColor: AppColors.pureWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isLarge, {bool isDiscount = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDiscount ? AppColors.errorRed : AppColors.textSecondary, fontSize: isLarge ? 16 : 14)),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? AppColors.errorRed : AppColors.primaryDark,
              fontSize: isBold ? 20 : (isLarge ? 16 : 14),
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
