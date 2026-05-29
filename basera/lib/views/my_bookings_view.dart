import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../viewmodels/booking_view_model.dart';
import '../core/constants/app_colors.dart';
import 'login_view.dart';

class MyBookingsView extends StatefulWidget {
  final String userId;
  final bool isGuest;

  const MyBookingsView({Key? key, required this.userId, this.isGuest = false}) : super(key: key);

  @override
  _MyBookingsViewState createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<MyBookingsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isGuest || widget.userId.isNotEmpty) {
        Provider.of<BookingViewModel>(context, listen: false).loadUserBookings(widget.userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cancelBooking(BuildContext context, String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel this booking? A refund may apply based on cancellation policy.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('Cancel Booking', style: TextStyle(color: AppColors.pureWhite)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final vm = Provider.of<BookingViewModel>(context, listen: false);
    await vm.cancelBooking(bookingId);
    vm.loadUserBookings(widget.userId);
  }

  List<BookingModel> _filterByTab(List<BookingModel> all, int tabIndex) {
    switch (tabIndex) {
      case 1: return all.where((b) => b.status == 'pending').toList();
      case 2: return all.where((b) => b.status == 'confirmed').toList();
      case 3: return all.where((b) => b.status == 'completed').toList();
      case 4: return all.where((b) => b.status == 'cancelled').toList();
      default: return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest && widget.userId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundBeige,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month_rounded, size: 70, color: AppColors.textHint),
              const SizedBox(height: 16),
              const Text('Sign in to view your bookings', style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginView())),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Sign In', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final vm = Provider.of<BookingViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            automaticallyImplyLeading: false,
            title: const Text('My Bookings', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold)),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.pureWhite,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppColors.accentSand,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Confirmed'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
        ],
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : vm.errorMessage != null
                ? Center(child: Text(vm.errorMessage!, style: const TextStyle(color: AppColors.errorRed)))
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(5, (tabIndex) {
                      final filtered = _filterByTab(vm.userBookings, tabIndex);
                      if (filtered.isEmpty) {
                        return _buildEmptyState(tabIndex);
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _buildBookingCard(context, filtered[i]),
                      );
                    }),
                  ),
      ),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    final messages = ['No bookings yet', 'No pending bookings', 'No confirmed bookings', 'No completed stays', 'No cancelled bookings'];
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded, size: 72, color: AppColors.textHint.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(tabIndex < messages.length ? messages[tabIndex] : 'No bookings', style: const TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    final statusConfig = _getStatusConfig(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Status Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusConfig['color'].withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusConfig['icon'] as IconData, color: statusConfig['color'] as Color, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(color: statusConfig['color'] as Color, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.8),
                    ),
                  ],
                ),
                Text(
                  'Rs.${booking.totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
          ),

          // Main Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.hotel_rounded, color: AppColors.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.roomTitle.isNotEmpty ? booking.roomTitle : 'Room Booking',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Text(
                                '${DateFormat('MMM d').format(DateTime.parse(booking.startDate))} → ${DateFormat('MMM d, yyyy').format(DateTime.parse(booking.endDate))}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPaymentBadge(booking.paymentStatus),
                    const Spacer(),
                    if (booking.status == 'pending')
                      GestureDetector(
                        onTap: () => _cancelBooking(context, booking.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.errorRed)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'confirmed':
        return {'color': AppColors.primaryGreen, 'icon': Icons.check_circle_rounded};
      case 'cancelled':
        return {'color': AppColors.errorRed, 'icon': Icons.cancel_rounded};
      case 'completed':
        return {'color': AppColors.primaryDark, 'icon': Icons.task_alt_rounded};
      default:
        return {'color': AppColors.accentSand, 'icon': Icons.hourglass_top_rounded};
    }
  }

  Widget _buildPaymentBadge(String status) {
    final isPaid = status == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPaid ? AppColors.lightGreen : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPaid ? Icons.check_rounded : Icons.pending_rounded, size: 13, color: isPaid ? AppColors.primaryGreen : Colors.orange),
          const SizedBox(width: 4),
          Text(
            'Payment: ${status.toUpperCase()}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPaid ? AppColors.primaryGreen : Colors.orange),
          ),
        ],
      ),
    );
  }
}
