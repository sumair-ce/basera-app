import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/login_view_model.dart';

class AdminBookingsView extends StatefulWidget {
  const AdminBookingsView({super.key});

  @override
  State<AdminBookingsView> createState() => _AdminBookingsViewState();
}

class _AdminBookingsViewState extends State<AdminBookingsView>
    with SingleTickerProviderStateMixin {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, String> _getHeaders() {
    final token =
        Provider.of<LoginViewModel>(
          context,
          listen: false,
        ).currentUser?.token ??
        '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/admin/bookings'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        setState(() {
          _bookings = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(
    Map<String, dynamic> booking,
    String newStatus,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/admin/bookings/${booking['_id']}'),
        headers: _getHeaders(),
        body: json.encode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        _fetchBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated to $newStatus'),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _deleteBooking(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Booking?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/admin/bookings/$id'),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        _fetchBookings();
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking deleted'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (_) {}
  }

  List<dynamic> _filterByStatus(List<dynamic> all, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return all.where((b) => b['status'] == 'pending').toList();
      case 2:
        return all.where((b) => b['status'] == 'confirmed').toList();
      case 3:
        return all.where((b) => b['status'] == 'completed').toList();
      case 4:
        return all.where((b) => b['status'] == 'cancelled').toList();
      default:
        return all;
    }
  }

  void _showStatusDialog(Map<String, dynamic> booking) {
    String current = booking['status'] ?? 'pending';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Update Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['pending', 'confirmed', 'completed', 'cancelled'].map((
              s,
            ) {
              return RadioListTile<String>(
                value: s,
                groupValue: current,
                activeColor: AppColors.primaryGreen,
                onChanged: (v) => setSt(() => current = v!),
                title: Text(
                  s.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _updateStatus(booking, current);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            title: const Text(
              'Manage Bookings',
              style: TextStyle(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.pureWhite,
                ),
                onPressed: _fetchBookings,
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.pureWhite,
              unselectedLabelColor: Colors.white60,
              indicatorColor: AppColors.accentSand,
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              )
            : TabBarView(
                controller: _tabController,
                children: List.generate(5, (tabIndex) {
                  final filtered = _filterByStatus(_bookings, tabIndex);
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No bookings in this category',
                        style: TextStyle(color: AppColors.textHint),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _buildBookingCard(filtered[i]),
                  );
                }),
              ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final statusColors = {
      'pending': AppColors.accentSand,
      'confirmed': AppColors.primaryGreen,
      'completed': AppColors.primaryDark,
      'cancelled': AppColors.errorRed,
    };
    final statusColor = statusColors[status] ?? AppColors.textHint;

    String? roomName;
    if (booking['roomId'] is Map) roomName = booking['roomId']['title'];
    String? userName;
    if (booking['userId'] is Map) {
      userName = booking['userId']['name'] ?? booking['userId']['email'];
    }

    String startDate = '';
    String endDate = '';
    try {
      startDate = DateFormat(
        'MMM d, yyyy',
      ).format(DateTime.parse(booking['startDate']));
      endDate = DateFormat(
        'MMM d, yyyy',
      ).format(DateTime.parse(booking['endDate']));
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Rs.${booking['totalPrice']?.toString() ?? '0'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (roomName != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.hotel_rounded,
                        size: 14,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          roomName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (userName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                if (startDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$startDate → $endDate',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showStatusDialog(booking),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: AppColors.primaryGreen,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Update Status',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _deleteBooking(booking['_id']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.errorRed,
                          size: 18,
                        ),
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
}
