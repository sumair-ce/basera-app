import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../viewmodels/login_view_model.dart';
import 'login_view.dart';
import 'profile_settings_view.dart';
import 'terms_conditions_view.dart';
import 'faq_view.dart';
import 'change_payment_details_view.dart';

class ProfileView extends StatelessWidget {
  final bool isGuest;

  const ProfileView({Key? key, this.isGuest = false}) : super(key: key);

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return Scaffold(
        backgroundColor: AppColors.backgroundBeige,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_off_rounded, size: 50, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 20),
              const Text('You are exploring as guest', style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Sign in to access your profile & bookings', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginView())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Sign In or Register', style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    }

    final loginVm = Provider.of<LoginViewModel>(context);
    final user = loginVm.currentUser;
    final name = user?.name ?? 'User';
    final email = user?.email ?? '';
    final initials = _getInitials(name);

    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.pureWhite),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.pureWhite)),
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      (user?.role ?? 'user').toUpperCase(),
                      style: const TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Menu Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_rounded,
                            color: AppColors.primaryGreen,
                            title: 'Profile Settings',
                            subtitle: 'Edit your personal info',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSettingsView())),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.payment_rounded,
                            color: AppColors.accentSand,
                            title: 'Payment Details',
                            subtitle: 'Manage payment methods',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePaymentDetailsView())),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.help_outline_rounded,
                            color: Colors.blue,
                            title: 'FAQ',
                            subtitle: 'Frequently asked questions',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqView())),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.description_rounded,
                            color: Colors.purple,
                            title: 'Terms & Conditions',
                            subtitle: 'Read our policies',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsView())),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
                            child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryGreen),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Basera App', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                              Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logout
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginView())),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.errorRed.withOpacity(0.2)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 20),
                            SizedBox(width: 10),
                            Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorRed, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 16, color: AppColors.borderGrey);
  }
}
