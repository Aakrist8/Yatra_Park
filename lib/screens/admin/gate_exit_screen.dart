import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yatra_park/core/constants/app_colors.dart';
import 'package:yatra_park/core/services/parking_state.dart';
import 'package:yatra_park/core/services/parking_repository.dart';

class GateExitScreen extends StatefulWidget {
  const GateExitScreen({super.key});

  @override
  State<GateExitScreen> createState() => _GateExitScreenState();
}

class _GateExitScreenState extends State<GateExitScreen> {
  final _supabase = Supabase.instance.client;
  final ParkingRepository _parkingRepo = ParkingRepository();

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  final TextEditingController _manualSearchController = TextEditingController();

  bool _isScanningActive = true;
  bool _isProcessingData = false;

  String _scannedVehiclePlate = "Waiting for Scan...";
  String _driverName = "None";
  String _scannedParkingBay = "None";
  String _calculatedParkingFee = "NPR 0.00";
  String _totalDurationText = "0 mins";

  bool _isSessionFound = false;
  String? _currentActiveSessionId;
  double _finalRawFareAmount = 0.0;

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanningActive || _isProcessingData) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String rawSessionId = barcodes.first.rawValue!.trim();

      _scannerController.stop();

      setState(() {
        _isScanningActive = false;
        _isProcessingData = true;
      });

      _fetchAndCalculateLiveExitFare(sessionId: rawSessionId);
    }
  }

  Future<void> _fetchAndCalculateLiveExitFare({String? sessionId, String? manualSearchQuery}) async {
    try {
      dynamic session;

      if (sessionId != null) {
        session = await _supabase
            .from('parking_sessions')
            .select()
            .eq('id', sessionId)
            .maybeSingle();
      } else if (manualSearchQuery != null && manualSearchQuery.isNotEmpty) {
        final List<dynamic> response = await _supabase
            .from('parking_sessions')
            .select()
            .eq('status', 'active')
            .or('vehicle_plate.ilike.%$manualSearchQuery%,driver_name.ilike.%$manualSearchQuery%');

        if (!mounted) return;

        if (response.isEmpty) {
          _showErrorSnackBar("No active parking session matches that input.");
          _resetExitFields();
          return;
        } else if (response.length > 1) {
          _showMultipleMatchesDialog(response);
          return;
        }
        session = response.first;
      }

      if (!mounted) return;

      if (session == null) {
        _showErrorSnackBar("Invalid Lookup: Record not found.");
        _resetExitFields();
        return;
      }

      if (session['status'] == 'completed') {
        _showErrorSnackBar("This session has already been closed.");
        _resetExitFields();
        return;
      }

      final double calculatedFare = _parkingRepo.calculateOutstandingFare(session['entry_time']);

      String rawEntry = session['entry_time'] ?? '';
      DateTime entryLocal;
      try {
        String clean = rawEntry.trim().replaceAll(' ', 'T');
        if (!clean.endsWith('Z') && !clean.contains('+')) {
          clean += 'Z';
        }
        entryLocal = DateTime.parse(clean).toLocal();
      } catch (_) {
        entryLocal = DateTime.now();
      }

      final Duration difference = DateTime.now().difference(entryLocal);
      final int totalMinutes = difference.isNegative ? 0 : difference.inMinutes;
      final int hours = totalMinutes ~/ 60;
      final int mins = totalMinutes % 60;

      setState(() {
        _currentActiveSessionId = session['id'];
        _scannedVehiclePlate = session['vehicle_plate'] ?? "UNKNOWN";
        _driverName = session['driver_name'] ?? "Guest Driver";
        _scannedParkingBay = session['assigned_bay'] ?? "N/A";

        _totalDurationText = "${hours}h ${mins}m";
        _calculatedParkingFee = "NPR ${calculatedFare.toStringAsFixed(2)}";

        _finalRawFareAmount = calculatedFare;
        _isSessionFound = true;
        _isProcessingData = false;
        _isScanningActive = false;
      });
    } catch (e) {
      debugPrint("Processing failure: $e");
      if (mounted) {
        _showErrorSnackBar("Database query error.");
        _resetExitFields();
      }
    }
  }

  void _showManualSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Manual Ticket Lookup",
          style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _manualSearchController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            hintText: "Enter Vehicle Plate or Driver Name...",
            hintStyle: const TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accentBlue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessingData = false;
              });
            },
            child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
            onPressed: () {
              final query = _manualSearchController.text.trim();
              Navigator.pop(context);
              if (query.isNotEmpty) {
                _scannerController.stop();
                setState(() {
                  _isProcessingData = true;
                });
                _fetchAndCalculateLiveExitFare(manualSearchQuery: query);
              } else {
                setState(() {
                  _isProcessingData = false;
                });
              }
            },
            child: const Text("Search", style: TextStyle(color: AppColors.textWhite)),
          )
        ],
      ),
    );
  }

  void _showMultipleMatchesDialog(List<dynamic> matches) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text("Select Active Vehicle", style: TextStyle(color: AppColors.textWhite)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final item = matches[index];
              return ListTile(
                title: Text(item['vehicle_plate'] ?? 'No Plate', style: const TextStyle(color: AppColors.textWhite)),
                subtitle: Text(
                  "Driver: ${item['driver_name']} | Bay: ${item['assigned_bay']}",
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.accentBlue, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _fetchAndCalculateLiveExitFare(sessionId: item['id']);
                },
              );
            },
          ),
        ),
      ),
    ).then((_) {
      if (!_isSessionFound && mounted) {
        _resetExitFields();
      }
    });
  }

  Future<void> _finalizeSessionClosure() async {
    if (_currentActiveSessionId == null) return;
    setState(() {
      _isProcessingData = true;
    });

    bool success = await _parkingRepo.closeActiveSession(_currentActiveSessionId!, _finalRawFareAmount);

    if (!mounted) return;

    if (success) {
      await parkingState.syncOccupancyFromDatabase();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Collected. Session Marked Completed & Gate Opened!"),
          backgroundColor: AppColors.successGreen,
        ),
      );
      _resetExitFields();
    } else {
      _showErrorSnackBar("Transaction error. Could not sync with database.");
      setState(() {
        _isProcessingData = false;
      });
    }
  }

  void _resetExitFields() {
    _scannerController.start();

    setState(() {
      _currentActiveSessionId = null;
      _manualSearchController.clear();
      _scannedVehiclePlate = "Waiting for Scan...";
      _driverName = "None";
      _scannedParkingBay = "None";
      _calculatedParkingFee = "NPR 0.00";
      _totalDurationText = "0 mins";
      _finalRawFareAmount = 0.0;
      _isSessionFound = false;
      _isProcessingData = false;
      _isScanningActive = true;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "GATE EXIT MODE",
                          style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 22),
                      onPressed: _resetExitFields,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isSessionFound ? AppColors.successGreen : AppColors.accentBlue,
                    width: 2.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(controller: _scannerController, onDetect: _onBarcodeDetected),
                      if (_isScanningActive)
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.4), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      if (_isProcessingData)
                        Container(
                          color: Colors.black.withValues(alpha: 0.6),
                          child: const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
                        ),
                      if (_isSessionFound)
                        Container(
                          color: Colors.black.withValues(alpha: 0.75),
                          child: const Center(
                            child: Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 50),
                          ),
                        )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Driver Name", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  _driverName,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Scanned Vehicle Number", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  _scannedVehiclePlate,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Assigned Bay", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              _scannedParkingBay,
                              style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Duration", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              _totalDurationText,
                              style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              const Text("Total Outstanding Fees", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  _calculatedParkingFee,
                  style: TextStyle(
                    color: _isSessionFound ? Colors.orangeAccent : AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Divider(color: AppColors.surfaceDark, thickness: 1.5),
              ),

              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.6), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: OutlinedButton.icon(
                  onPressed: _isProcessingData ? null : _showManualSearchDialog,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.search_rounded, color: AppColors.accentBlue),
                  label: const Text(
                    "MANUAL SEARCH TICKET",
                    style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                height: 54,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: _isSessionFound ? AppColors.successGreen : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextButton(
                  onPressed: (_isSessionFound && !_isProcessingData) ? _finalizeSessionClosure : null,
                  child: _isProcessingData
                      ? const CircularProgressIndicator(color: AppColors.textWhite)
                      : Text(
                    "COLLECT PAYMENT & OPEN GATE",
                    style: TextStyle(
                      color: _isSessionFound ? AppColors.textWhite : AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}