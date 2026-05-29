import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ManagerDashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard', style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 100, color: AppColors.primaryGreen),
            const SizedBox(height: 20),
            const Text(
              'Welcome, Manager.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.fact_check),
              label: const Text('Verify Pending Payments'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentSand,
                foregroundColor: AppColors.pureWhite,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.room_preferences),
              label: const Text('Manage Room Availability'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.pureWhite,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
