import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yatra_park/core/constants/app_colors.dart';
import 'package:yatra_park/core/services/parking_repository.dart';

class ParkingRecord {
  final String id;
  final String vehiclePlate;
  final String driverName;
  final String bay;
  final DateTime entryTime;
  final String feePaid;
  final bool isActive;
  final String rawEntryString;

  ParkingRecord({
    required this.id,
    required this.vehiclePlate,
    required this.driverName,
    required this.bay,
    required this.entryTime,
    required this.feePaid,
    required this.isActive,
    required this.rawEntryString,
  });

  factory ParkingRecord.fromMap(Map<String, dynamic> map, ParkingRepository repository) {
    final bool active = (map['status'] == 'active');
    final String rawEntry = map['entry_time'] ?? '';

    final DateTime entry = _parseLocalTime(rawEntry);

    double fee = 0.0;
    if (active) {
      fee = repository.calculateOutstandingFare(rawEntry);
    } else {
      fee = (map['current_fare'] as num?)?.toDouble() ?? 0.0;
    }

    return ParkingRecord(
      id: map['id']?.toString() ?? '',
      vehiclePlate: map['vehicle_plate'] ?? 'UNKNOWN',
      driverName: map['driver_name'] ?? 'Guest Driver',
      bay: map['assigned_bay'] ?? 'N/A',
      entryTime: entry,
      feePaid: "Rs. ${fee.toStringAsFixed(2)}",
      isActive: active,
      rawEntryString: rawEntry,
    );
  }

  static DateTime _parseLocalTime(String raw) {
    try {
      if (raw.trim().isEmpty) return DateTime.now();
      String clean = raw.trim().replaceAll(' ', 'T');
      if (!clean.endsWith('Z') && !clean.contains('+')) {
        clean += 'Z';
      }
      return DateTime.parse(clean).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _supabase = Supabase.instance.client;
  final ParkingRepository _repository = ParkingRepository();
  final TextEditingController _searchController = TextEditingController();

  List<ParkingRecord> _allLogs = [];
  List<ParkingRecord> _filteredLogs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDatabaseLogs();
    _searchController.addListener(_performSearchFilter);
  }

  Future<void> _fetchDatabaseLogs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Clean query: exit_time removed completely
      final response = await _supabase
          .from('parking_sessions')
          .select('id, status, entry_time, current_fare, vehicle_plate, driver_name, assigned_bay')
          .order('entry_time', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      final List<ParkingRecord> loadedLogs = data
          .map((row) => ParkingRecord.fromMap(row as Map<String, dynamic>, _repository))
          .toList();

      if (!mounted) return;

      setState(() {
        _allLogs = loadedLogs;
        _isLoading = false;
      });
      _performSearchFilter();
    } catch (e) {
      debugPrint("Failed to fetch history logs: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = "Could not load transaction logs from server.";
        _isLoading = false;
      });
    }
  }

  void _performSearchFilter() {
    if (!mounted) return;
    final query = _searchController.text.trim().toUpperCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLogs = _allLogs;
      } else {
        _filteredLogs = _allLogs.where((log) {
          return log.vehiclePlate.toUpperCase().contains(query) ||
              log.driverName.toUpperCase().contains(query) ||
              log.bay.toUpperCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearchFilter);
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 20),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
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
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 20),
                      onPressed: _fetchDatabaseLogs,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                    onPressed: () => _searchController.clear(),
                  )
                      : null,
                  hintText: "Search Plate, Driver, or Bay...",
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Transactions",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  if (!_isLoading)
                    Text(
                      "${_filteredLogs.length} entries",
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _buildLogContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accentBlue));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
              onPressed: _fetchDatabaseLogs,
              child: const Text("Retry", style: TextStyle(color: AppColors.textWhite)),
            ),
          ],
        ),
      );
    }

    if (_filteredLogs.isEmpty) {
      return const Center(
        child: Text("No records found matching query.", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
      );
    }

    return RefreshIndicator(
      color: AppColors.accentBlue,
      backgroundColor: AppColors.surfaceDark,
      onRefresh: _fetchDatabaseLogs,
      child: ListView.builder(
        itemCount: _filteredLogs.length,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemBuilder: (context, index) {
          final log = _filteredLogs[index];
          return StopwatchParkingTile(
            key: ValueKey(log.id),
            log: log,
            repository: _repository,
          );
        },
      ),
    );
  }
}

class StopwatchParkingTile extends StatefulWidget {
  final ParkingRecord log;
  final ParkingRepository repository;

  const StopwatchParkingTile({
    super.key,
    required this.log,
    required this.repository,
  });

  @override
  State<StopwatchParkingTile> createState() => _StopwatchParkingTileState();
}

class _StopwatchParkingTileState extends State<StopwatchParkingTile> {
  Timer? _stopwatchTimer;
  late Duration _elapsedDuration;
  late double _currentFare;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant StopwatchParkingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.log.id != widget.log.id || oldWidget.log.isActive != widget.log.isActive) {
      _stopwatchTimer?.cancel();
      _startTimer();
    }
  }

  void _startTimer() {
    _updateState();

    if (widget.log.isActive) {
      _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _updateState();
        });
      });
    }
  }

  void _updateState() {
    if (widget.log.isActive) {
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(widget.log.entryTime);
      _elapsedDuration = difference.isNegative ? Duration.zero : difference;
      _currentFare = widget.repository.calculateOutstandingFare(widget.log.rawEntryString);
    } else {
      _elapsedDuration = Duration.zero;
      _currentFare = 0.0;
    }
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    super.dispose();
  }

  String _formatStopwatch(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);

    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final String hh = hours.toString().padLeft(2, '0');
      return "$hh:$mm:$ss";
    }
    return "$mm:$ss";
  }

  @override
  Widget build(BuildContext context) {
    final log = widget.log;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.vehiclePlate,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Driver: ${log.driverName}  •  ${log.bay}",
                  style: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      log.isActive ? Icons.timer_outlined : Icons.check_circle_outline,
                      size: 15,
                      color: log.isActive ? AppColors.accentBlue : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log.isActive ? _formatStopwatch(_elapsedDuration) : "Completed",
                      style: TextStyle(
                        color: log.isActive ? AppColors.accentBlue : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (log.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "PARKED",
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                log.isActive ? "Rs. ${_currentFare.toStringAsFixed(2)}" : log.feePaid,
                style: TextStyle(
                  color: log.isActive ? Colors.orangeAccent : AppColors.successGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                log.isActive ? "Active Fare" : "Completed",
                style: TextStyle(
                  color: log.isActive
                      ? AppColors.textMuted
                      : AppColors.successGreen.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}