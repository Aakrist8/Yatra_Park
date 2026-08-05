import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yatra_park/core/constants/app_colors.dart';
import 'package:yatra_park/models/user_profile.dart';

class ProfilePage extends StatelessWidget {
  final UserProfile userProfile;

  const ProfilePage({
    super.key,
    required this.userProfile,
  });

  void _handleSignOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🧠 Check if a vehicle number has been scanned yet
    final bool isVehicleScanned = userProfile.scannedVehicleNumber != null &&
        userProfile.scannedVehicleNumber!.isNotEmpty;

    final String vehicleSubtitle = isVehicleScanned
        ? "1 Vehicle - ${userProfile.scannedVehicleNumber}"
        : "1 Vehicle - BA ** ** ****"; // Masked initial state

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Profile avatar
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.successGreen,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.successGreen.withOpacity(0.05),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: AppColors.surfaceDark,
                child: Text(
                  userProfile.name.isNotEmpty
                      ? userProfile.name.substring(0, userProfile.name.length >= 2 ? 2 : 1).toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Name & Email
            Text(
              userProfile.name,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userProfile.email,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 32),

            // Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.settings_outlined,
                    title: "Account Settings",
                  ),
                  const SizedBox(height: 16),

                  // 🧠 Displays masked or revealed vehicle number based on scan status
                  _buildProfileTile(
                    icon: Icons.directions_car_outlined,
                    title: "My Vehicles",
                    subtitle: vehicleSubtitle,
                    isVerified: isVehicleScanned,
                  ),

                  const SizedBox(height: 16),

                  _buildProfileTile(
                    icon: Icons.info_outline,
                    title: "Support & Help",
                  ),

                  const SizedBox(height: 24),

                  // Sign Out
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextButton(
                      onPressed: () => _handleSignOut(context),
                      child: const Text(
                        "Sign Out",
                        style: TextStyle(
                          color: AppColors.errorRed,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isVerified = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.successGreen,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isVerified ? AppColors.accentBlue : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: isVerified ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}