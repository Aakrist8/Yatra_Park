import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yatra_park/core/constants/app_colors.dart';

class UserDashboard extends StatefulWidget {
  final String searchedPlate; // Vehicle plate number or session ticket ID

  const UserDashboard({
    super.key,
    required this.searchedPlate,
  });

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final _supabase = Supabase.instance.client;

  // Real-time states
  Map<String, dynamic>? _activeSession;
  StreamSubscription<List<Map<String, dynamic>>>? _streamSubscription;
  Timer? _tickerTimer;
  Duration _currentDuration = Duration.zero;
  double _currentFare = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessionDirectly();
    _subscribeToSearchedSession();
  }

  /// Direct REST query fallback for instant initial load
  Future<void> _fetchSessionDirectly() async {
    final cleanPlate = widget.searchedPlate.trim();
    if (cleanPlate.isEmpty) return;

    try {
      // Search by vehicle plate first
      Map<String, dynamic>? session = await _supabase
          .from('parking_sessions')
          .select()
          .ilike('vehicle_plate', '%$cleanPlate%')
          .eq('status', 'active')
          .maybeSingle();

      // Fallback search by ID
      if (session == null) {
        try {
          session = await _supabase
              .from('parking_sessions')
              .select()
              .eq('id', cleanPlate)
              .eq('status', 'active')
              .maybeSingle();
        } catch (_) {}
      }

      if (mounted && session != null) {
        setState(() {
          _activeSession = session;
          _isLoading = false;
        });
        _startLiveTicker();
      }
    } catch (e) {
      debugPrint("Direct fetch error: $e");
    }
  }

  /// Realtime Stream listener for live session updates
  void _subscribeToSearchedSession() {
    final cleanPlate = widget.searchedPlate.trim().toUpperCase();

    _streamSubscription?.cancel();

    _streamSubscription = _supabase
        .from('parking_sessions')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      final matchingSessions = data.where((session) {
        final plate = session['vehicle_plate']?.toString().toUpperCase() ?? '';
        final id = session['id']?.toString() ?? '';
        final status = session['status']?.toString().toLowerCase() ?? '';

        return (plate.contains(cleanPlate) || id == cleanPlate) && status == 'active';
      }).toList();

      if (matchingSessions.isNotEmpty) {
        setState(() {
          _activeSession = matchingSessions.first;
          _isLoading = false;
        });
        _startLiveTicker();
      } else if (_activeSession == null) {
        setState(() {
          _isLoading = false;
        });
      }
    }, onError: (error) {
      debugPrint("Supabase Stream Error Diagnostic: $error");
      if (mounted && _activeSession == null) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Ticking timer & dynamic fare calculation
  void _startLiveTicker() {
    _tickerTimer?.cancel();

    if (_activeSession == null || _activeSession!['entry_time'] == null) return;

    DateTime entryTime = DateTime.parse(_activeSession!['entry_time']).toLocal();

    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final now = DateTime.now();
      final difference = now.difference(entryTime);

      // Base fare: NPR 60 for 1st hour
      double calculatedFare = 60.0;

      // NPR 30 for every additional hour or fraction of an hour
      if (difference.inMinutes > 60) {
        int remainingMinutes = difference.inMinutes - 60;
        int additionalHours = (remainingMinutes / 60).ceil();
        calculatedFare += additionalHours * 30.0;
      }

      setState(() {
        _currentDuration = difference;
        _currentFare = _activeSession!['current_fare']?.toDouble() ?? calculatedFare;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${hours}h : ${minutes}m : ${seconds}s";
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.primaryDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentBlue),
        ),
      );
    }

    // When plate input does not match any active parking session
    if (_activeSession == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  "No active session found for '${widget.searchedPlate}'",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please verify the license plate or ticket ID and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Extract dynamic metadata from Supabase record
    final vehiclePlate = _activeSession!['vehicle_plate'] ?? widget.searchedPlate;
    final registeredName = _activeSession!['registered_name'] ??
        _activeSession!['user_name'] ??
        _activeSession!['driver_name'] ??
        'Registered Driver';
    final bayNumber = _activeSession!['bay_number'] ??
        _activeSession!['bay'] ??
        _activeSession!['parking_slot'] ??
        'Bay B-04';

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade400, width: 1),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.circle, color: Colors.green, size: 10),
                            SizedBox(width: 8),
                            Text(
                              "ACTIVE SESSION",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Plate Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "VEHICLE NUMBER",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehiclePlate.toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car_filled_outlined,
                            color: AppColors.accentBlue,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2x2 Grid Metrics: Time, Fare, Bay, Name
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.15,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Card 1: Time Elapsed
                        _buildMetricCard(
                          icon: Icons.timer_outlined,
                          iconColor: Colors.amber,
                          label: "ELAPSED TIME",
                          value: _formatDuration(_currentDuration),
                        ),

                        // Card 2: Current Fare
                        _buildMetricCard(
                          icon: Icons.payments_outlined,
                          iconColor: Colors.greenAccent,
                          label: "CURRENT FARE",
                          value: "NPR ${_currentFare.toStringAsFixed(2)}",
                        ),

                        // Card 3: Parked Bay
                        _buildMetricCard(
                          icon: Icons.local_parking_outlined,
                          iconColor: Colors.blueAccent,
                          label: "PARKED BAY",
                          value: bayNumber.toString(),
                        ),

                        // Card 4: Registered Name
                        _buildMetricCard(
                          icon: Icons.person_outline,
                          iconColor: Colors.purpleAccent,
                          label: "REGISTERED TO",
                          value: registeredName.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Interactive QR Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.28,
            minChildSize: 0.28,
            maxChildSize: 0.85,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        "DRAG FOR QR",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        "Present to Exit Gate Attendant",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // QR Display
                    Center(
                      child: Container(
                        width: 260,
                        height: 260,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(
                          Icons.qr_code_2,
                          size: 220,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        "This QR contains your active session ID for instant validation.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Helper widget for rendering status cards
  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}