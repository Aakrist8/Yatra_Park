import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yatra_park/core/constants/app_colors.dart';
import 'package:yatra_park/models/user_profile.dart';
import 'package:yatra_park/screens/user/booking_history.dart';
import 'package:yatra_park/screens/user/profile_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  String? _scannedInput;
  Map<String, dynamic>? _activeSessionData;
  bool _isLoadingSession = false;

  @override
  void initState() {
    super.initState();
    // Removed automatic session fetching on login to keep the home screen clean!
  }

  /// Fetches details from Supabase ONLY when user types a Vehicle Plate or Ticket ID
  Future<void> _fetchAndDisplaySession(String query) async {
    final cleanInput = query.trim();
    if (cleanInput.isEmpty) return;

    setState(() {
      _isLoadingSession = true;
      _scannedInput = cleanInput;
    });

    try {
      final supabase = Supabase.instance.client;
      Map<String, dynamic>? response;

      // 1. Primary search: By vehicle plate (supports partial or exact match)
      response = await supabase
          .from('parking_sessions')
          .select()
          .ilike('vehicle_plate', '%$cleanInput%')
          .eq('status', 'active')
          .maybeSingle();

      // 2. Secondary fallback: If plate search comes back empty, attempt matching by ID
      if (response == null) {
        try {
          response = await supabase
              .from('parking_sessions')
              .select()
              .eq('id', cleanInput)
              .eq('status', 'active')
              .maybeSingle();
        } catch (_) {
          // Ignores UUID/integer format errors if cleanInput is purely plate text
        }
      }

      if (!mounted) return;

      if (response != null) {
        setState(() {
          _activeSessionData = response;
          _isLoadingSession = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Loaded parking session for ${response['vehicle_plate']}"),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        setState(() {
          _activeSessionData = null;
          _isLoadingSession = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No active parking session found for '$cleanInput'"),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching parking session: $e");
      if (mounted) {
        setState(() => _isLoadingSession = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to retrieve session for '$cleanInput'."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  UserProfile _getUserProfile() {
    final user = Supabase.instance.client.auth.currentUser;
    final userMetadata = user?.userMetadata;

    final String name = userMetadata?['name'] as String? ??
        (user?.email != null && user!.email!.contains('@')
            ? user.email!.split('@').first
            : 'User');

    return UserProfile(
      name: name,
      email: user?.email ?? 'No email provided',
      scannedVehicleNumber: _scannedInput,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = _getUserProfile();

    final List<Widget> pages = [
      _HomeContentView(
        userName: userProfile.name,
        activeSession: _activeSessionData,
        isLoadingSession: _isLoadingSession,
        onInputSubmit: _fetchAndDisplaySession,
        onClearSession: () {
          setState(() {
            _activeSessionData = null;
            _scannedInput = null;
          });
        },
      ),
      const BookingHistoryPage(),
      ProfilePage(userProfile: userProfile),
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textMuted,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _HomeContentView extends StatelessWidget {
  final String userName;
  final Map<String, dynamic>? activeSession;
  final bool isLoadingSession;
  final Function(String input) onInputSubmit;
  final VoidCallback onClearSession;

  const _HomeContentView({
    required this.userName,
    this.activeSession,
    required this.isLoadingSession,
    required this.onInputSubmit,
    required this.onClearSession,
  });

  void _openQrScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Scan Entry QR Code",
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MobileScanner(
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          final String code = barcode.rawValue!;
                          Navigator.pop(modalContext);
                          onInputSubmit(code);
                          break;
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                "Align the parking QR code within the frame",
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualInputDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Enter Vehicle or Ticket ID",
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Type your vehicle number or ticket code to load live parking details.",
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: "e.g., BA 2 CH 1234",
                hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.6)),
                filled: true,
                fillColor: AppColors.primaryDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Cancel",
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final String input = textController.text.trim();
              if (input.isNotEmpty) {
                Navigator.pop(dialogContext);
                onInputSubmit(input);
              }
            },
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              "Hello $userName,",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const Text(
              "Welcome to Yatra Park",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),

            if (isLoadingSession)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                ),
              )
            else if (activeSession != null)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActiveSessionCard(
                      sessionData: activeSession!,
                      onClear: onClearSession,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accentBlue),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showManualInputDialog(context),
                      icon: const Icon(Icons.search, color: AppColors.accentBlue),
                      label: const Text("SEARCH ANOTHER VEHICLE", style: TextStyle(color: AppColors.accentBlue)),
                    )
                  ],
                ),
              )
            else
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _openQrScanner(context),
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceDark,
                                border: Border.all(
                                  color: AppColors.accentBlue,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentBlue.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 60,
                                    color: AppColors.textWhite,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "SCAN ENTRY QR",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          TextButton.icon(
                            onPressed: () => _showManualInputDialog(context),
                            icon: const Icon(
                              Icons.keyboard_outlined,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                            label: const Text(
                              "Camera not working? Enter manually",
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSessionCard extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  final VoidCallback onClear;

  const _ActiveSessionCard({
    required this.sessionData,
    required this.onClear,
  });

  @override
  State<_ActiveSessionCard> createState() => _ActiveSessionCardState();
}

class _ActiveSessionCardState extends State<_ActiveSessionCard> {
  Timer? _timer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    final entryTimeString = widget.sessionData['entry_time'] as String?;
    if (entryTimeString != null) {
      final entryTime = DateTime.parse(entryTimeString);
      _duration = DateTime.now().difference(entryTime);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _duration = DateTime.now().difference(entryTime);
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final plate = widget.sessionData['vehicle_plate'] ?? "UNKNOWN";
    final bay = widget.sessionData['assigned_bay'] ?? "N/A";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "ACTIVE PARKING SESSION",
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                onPressed: widget.onClear,
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            plate,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Assigned Bay: $bay",
            style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Text(
                  "TOTAL ELAPSED TIME",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(
                    color: AppColors.accentBlue,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}