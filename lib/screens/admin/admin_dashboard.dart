import 'package:flutter/material.dart';
import 'package:yatra_park/core/constants/app_colors.dart';
import 'gate_entry_screen.dart';
import 'gate_exit_screen.dart';
import 'record.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "YATRA PARK",
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Parking Management System",
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_parking_rounded, color: AppColors.accentBlue, size: 28),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- LIVE LOT STATUS METRICS ---
              const Text(
                "Live Lot Status",
                style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricTile("TOTAL BAYS", "50", AppColors.textWhite),
                    Container(width: 1, height: 40, color: AppColors.textMuted.withOpacity(0.15)),
                    _buildMetricTile("OCCUPIED", "36", AppColors.accentBlue),
                    Container(width: 1, height: 40, color: AppColors.textMuted.withOpacity(0.15)),
                    _buildMetricTile("AVAILABLE", "14", AppColors.successGreen),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // --- OPERATIONS MENU PANELS ---
              const Text(
                "Operations Menu",
                style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 1. GATE ENTRY PANEL
              _buildMenuPanel(
                title: "GATE ENTRY STATION",
                subtitle: "Check-in incoming vehicles & print codes",
                icon: Icons.login_rounded,
                accentColor: AppColors.successGreen,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GateEntryScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 2. GATE EXIT PANEL
              _buildMenuPanel(
                title: "GATE EXIT STATION",
                subtitle: "Scan live tickets & calculate runtime fees",
                icon: Icons.logout_rounded,
                accentColor: Colors.orangeAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GateExitScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 3. SYSTEM LOGS & HISTORY PANEL
              _buildMenuPanel(
                title: "SYSTEM LOGS & HISTORY",
                subtitle: "View active sessions & transaction records",
                icon: Icons.history_toggle_off_rounded,
                accentColor: AppColors.accentBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to cleanly assemble lot calculations layout
  Widget _buildMetricTile(String title, String dataValue, Color dataColor) {
    return Column(
      children: [
        Text(
          dataValue,
          style: TextStyle(color: dataColor, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Helper widget to maintain architectural card aesthetics
  Widget _buildMenuPanel({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}