import 'package:flutter/material.dart';
import 'package:yatra_park/core/constants/app_colors.dart';

// Blueprint structure for a parking log entry
class ParkingRecord {
  final String vehiclePlate;
  final String bay;
  final String entryTime;
  final String exitTime;
  final String duration;
  final String feePaid;
  final bool isActive;

  ParkingRecord({
    required this.vehiclePlate,
    required this.bay,
    required this.entryTime,
    required this.exitTime,
    required this.duration,
    required this.feePaid,
    required this.isActive,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock master database dataset
  final List<ParkingRecord> _masterLogs = [
    ParkingRecord(vehiclePlate: "BA 2 CH 8841", bay: "Bay: A12", entryTime: "10:15 AM", exitTime: "12:30 PM", duration: "2h 15m", feePaid: "Rs. 75.00", isActive: false),
    ParkingRecord(vehiclePlate: "PRO 3 Z 9921", bay: "Bay: B04", entryTime: "11:00 AM", exitTime: "Current", duration: "1h 35m", feePaid: "Rs. 0.00", isActive: true),
    ParkingRecord(vehiclePlate: "BA 1 PA 4567", bay: "Bay: C01", entryTime: "08:45 AM", exitTime: "02:15 PM", duration: "5h 30m", feePaid: "Rs. 165.00", isActive: false),
    ParkingRecord(vehiclePlate: "ME 4 CH 1122", bay: "Bay: A02", entryTime: "01:10 PM", exitTime: "Current", duration: "0h 45m", feePaid: "Rs. 0.00", isActive: true),
    ParkingRecord(vehiclePlate: "BA 3 PA 7788", bay: "Bay: B11", entryTime: "07:30 AM", exitTime: "10:00 AM", duration: "2h 30m", feePaid: "Rs. 75.00", isActive: false),
  ];

  List<ParkingRecord> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _filteredLogs = _masterLogs; // Initialize list view display target
    _searchController.addListener(_performSearchFilter);
  }

  void _performSearchFilter() {
    final query = _searchController.text.trim().toUpperCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLogs = _masterLogs;
      } else {
        _filteredLogs = _masterLogs.where((log) => log.vehiclePlate.contains(query)).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 20),
                      onPressed: () {}, // Handled during final dashboard stitching
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "SYSTEM LOGS",
                          style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40), // Balance spacing layout
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- SEARCH BAR ELEMENT ---
              TextFormField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  hintText: "Search Plate Number...",
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 24),

              // --- SEARCH RESULT COUNT OR LIST ---
              const Text(
                "Recent Transactions",
                style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _filteredLogs.isEmpty
                    ? const Center(
                  child: Text(
                    "No records found matching query.",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                )
                    : ListView.builder(
                  itemCount: _filteredLogs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final log = _filteredLogs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left details column block
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.vehiclePlate,
                                style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(log.bay, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                  const SizedBox(width: 8),
                                  Text("•", style: TextStyle(color: AppColors.textMuted.withOpacity(0.5))),
                                  const SizedBox(width: 8),
                                  Text(log.duration, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${log.entryTime} → ${log.exitTime}",
                                style: TextStyle(color: AppColors.textMuted.withOpacity(0.7), fontSize: 11),
                              )
                            ],
                          ),
                          // Right operational status/fee badge indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: log.isActive
                                  ? AppColors.accentBlue.withOpacity(0.12)
                                  : AppColors.successGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              log.isActive ? "ACTIVE" : log.feePaid,
                              style: TextStyle(
                                color: log.isActive ? AppColors.accentBlue : AppColors.successGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}