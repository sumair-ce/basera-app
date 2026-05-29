import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../viewmodels/payment_view_model.dart';
import '../core/constants/app_colors.dart';

class MyPaymentsView extends StatefulWidget {
  final String userId;
  final bool isGuest;

  const MyPaymentsView({Key? key, required this.userId, this.isGuest = false}) : super(key: key);

  @override
  _MyPaymentsViewState createState() => _MyPaymentsViewState();
}

class _MyPaymentsViewState extends State<MyPaymentsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isGuest || widget.userId.isNotEmpty) {
        Provider.of<PaymentViewModel>(context, listen: false).loadUserPayments(widget.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest && widget.userId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundBeige,
        appBar: AppBar(title: const Text('My Payments'), backgroundColor: AppColors.primaryDark),
        body: const Center(child: Text('Please log in to view your payments.', style: TextStyle(fontSize: 18, color: AppColors.textSecondary))),
      );
    }

    final vm = Provider.of<PaymentViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        title: const Text('Transaction History', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : vm.errorMessage != null
              ? Center(child: Text(vm.errorMessage!, style: const TextStyle(color: AppColors.errorRed)))
              : vm.payments.isEmpty
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 80, color: AppColors.textHint.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('No payments found.', style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      ],
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: vm.payments.length,
                      itemBuilder: (context, index) {
                        return _buildPaymentCard(vm.payments[index]);
                      },
                    ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    Color statusColor = AppColors.textHint;
    IconData statusIcon = Icons.hourglass_empty_rounded;
    
    if (payment.status == 'verified') {
      statusColor = AppColors.primaryGreen;
      statusIcon = Icons.check_circle_rounded;
    }
    if (payment.status == 'rejected') {
      statusColor = AppColors.errorRed;
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.backgroundBeige, shape: BoxShape.circle),
          child: Icon(Icons.attach_money_rounded, color: AppColors.accentSand, size: 28),
        ),
        title: Text(payment.roomTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(DateFormat('MMM d, yyyy - h:mm a').format(DateTime.parse(payment.createdAt)), style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(payment.status.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
              ],
            )
          ],
        ),
        trailing: Text('\$${payment.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
      ),
    );
  }
}
