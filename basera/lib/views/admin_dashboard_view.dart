import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/login_view_model.dart';
import 'login_view.dart';
import 'admin_users_view.dart';
import 'admin_bookings_view.dart';
import 'admin_faqs_view.dart';
import 'admin_terms_view.dart';
import 'admin_hostels_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  Map<String, dynamic> _stats = {};
  bool _loadingStats = true;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchStats());
  }

  Future<void> _fetchStats() async {
    try {
      // Fetch bookings count
      final bRes = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/admin/bookings'),
        headers: _getHeaders(),
      );
      final uRes = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/admin/users'),
        headers: _getHeaders(),
      );
      final hRes = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/admin/hostels'),
        headers: _getHeaders(),
      );

      if (mounted) {
        setState(() {
          final bookings = bRes.statusCode == 200
              ? (json.decode(bRes.body) as List)
              : [];
          final users = uRes.statusCode == 200
              ? (json.decode(uRes.body) as List)
              : [];
          final hostels = hRes.statusCode == 200
              ? (json.decode(hRes.body) as List)
              : [];

          final pending = bookings
              .where((b) => b['status'] == 'pending')
              .length;
          final confirmed = bookings
              .where((b) => b['status'] == 'confirmed')
              .length;

          _stats = {
            'totalBookings': bookings.length,
            'pendingBookings': pending,
            'confirmedBookings': confirmed,
            'totalUsers': users.length,
            'totalHostels': hostels.length,
          };
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginVm = Provider.of<LoginViewModel>(context);
    final name = loginVm.currentUser?.name ?? 'Admin';
    final role = loginVm.currentUser?.role ?? 'admin';

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Admin Panel',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                color: AppColors.pureWhite,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.pureWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => LoginView()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.pureWhite,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Stats Row
                    if (_loadingStats)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white60),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatChip(
                              'Total\nBookings',
                              '${_stats['totalBookings'] ?? 0}',
                              Icons.book_online_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatChip(
                              'Pending',
                              '${_stats['pendingBookings'] ?? 0}',
                              Icons.hourglass_top_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatChip(
                              'Users',
                              '${_stats['totalUsers'] ?? 0}',
                              Icons.group_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatChip(
                              'Hostels',
                              '${_stats['totalHostels'] ?? 0}',
                              Icons.apartment_rounded,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Text(
                  'Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),

              // Action Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [
                    _buildActionCard(
                      context,
                      'Manage Users',
                      Icons.group_rounded,
                      const [Color(0xFF1A6B3C), Color(0xFF2E9E5E)],
                      '${_stats['totalUsers'] ?? ''} users',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUsersView(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Manage Bookings',
                      Icons.book_online_rounded,
                      const [Color(0xFF1565C0), Color(0xFF1976D2)],
                      '${_stats['totalBookings'] ?? ''} total',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminBookingsView(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Manage Hostels',
                      Icons.apartment_rounded,
                      const [Color(0xFFE65100), Color(0xFFF57C00)],
                      '${_stats['totalHostels'] ?? ''} hostels',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminHostelsView(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Manage FAQs',
                      Icons.quiz_rounded,
                      const [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      'Content management',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminFaqsView(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Terms & Conditions',
                      Icons.policy_rounded,
                      const [Color(0xFF00695C), Color(0xFF00897B)],
                      'Legal content',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminTermsView(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Pending Payments',
                      Icons.payments_rounded,
                      const [Color(0xFFC62828), Color(0xFFE53935)],
                      '${_stats['pendingBookings'] ?? ''} pending',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminBookingsView(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.pureWhite, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.pureWhite,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradColors,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradColors[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.pureWhite, size: 26),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
