import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:yatra_park/core/constants/app_colors.dart';

class GateExitScreen extends StatefulWidget {
  const GateExitScreen({super.key});

  @override
  State<GateExitScreen> createState() => _GateExitScreenState();
}

class _GateExitScreenState extends State<GateExitScreen> {
  // Mobile scanner configuration parameters
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isScanningActive = true;

  String _scannedVehiclePlate = "Waiting for Scan...";
  String _scannedParkingBay = "None";
  String _calculatedParkingFee = "Rs. 0.00";
  String _totalDurationText = "0 mins";
  bool _isSessionFound = false;

  // Set your desired billing configuration parameter here (e.g., Rs. 30 per hour)
  final double _hourlyRate = 30.0;

  // This monitors the raw streaming frame parameters from the camera array
  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanningActive) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String rawPayload = barcodes.first.rawValue!;

      setState(() {
        _isScanningActive = false; // Halt scanning instantly to avoid multiple trigger loops
      });

      _calculateDynamicRuntimeFee(rawPayload);
    }
  }

  // Decodes entry string payload parameters and calculates fare dynamically at runtime
  void _calculateDynamicRuntimeFee(String payload) {
    try {
      // Expects format generated at entry: "Vehicle: BA 2 CH 1234 | Position : Bay: A12 | EntryTime : 2026-06-02..."
      if (payload.contains("Vehicle:") && payload.contains("Position :")) {
        final parts = payload.split('|');
        final platePart = parts[0].replaceAll("Vehicle:", "").trim();
        final bayPart = parts[1].replaceAll("Position :", "").trim();

        DateTime entryTimestamp = DateTime.now().subtract(const Duration(hours: 1, minutes: 45)); // Safe calculation dynamic fallback

        if (parts.length > 2 && parts[2].contains("EntryTime :")) {
          final timePart = parts[2].replaceAll("EntryTime :", "").trim();
          entryTimestamp = DateTime.parse(timePart);
        }

        // TIME CALCULATION MATRIX RUNTIME
        final DateTime exitTimestamp = DateTime.now();
        final Duration dynamicStayDuration = exitTimestamp.difference(entryTimestamp);

        final int totalMinutes = dynamicStayDuration.inMinutes;
        final double fractionalHours = totalMinutes / 60.0;

        double totalBill = fractionalHours * _hourlyRate;
        if (totalBill < _hourlyRate) totalBill = _hourlyRate; // Charge a base minimum single hour constraint

        setState(() {
          _scannedVehiclePlate = platePart;
          _scannedParkingBay = bayPart;
          _totalDurationText = "${dynamicStayDuration.inHours}h ${totalMinutes % 60}m";
          _calculatedParkingFee = "Rs. ${totalBill.toStringAsFixed(2)}";
          _isSessionFound = true;
        });
      } else {
        // Handle scanning a generic barcode that isn't from Yatra Park
        setState(() {
          _scannedVehiclePlate = "Invalid QR System Code";
          _scannedParkingBay = "Unknown";
          _totalDurationText = "0m";
          _calculatedParkingFee = "Rs. 0.00";
          _isSessionFound = false;
          _isScanningActive = true;
        });
      }
    } catch (e) {
      debugPrint("Parsing or timestamp integration runtime error: $e");
      _resetExitFields();
    }
  }

  void _resetExitFields() {
    setState(() {
      _scannedVehiclePlate = "Waiting for Scan...";
      _scannedParkingBay = "None";
      _calculatedParkingFee = "Rs. 0.00";
      _totalDurationText = "0 mins";
      _isSessionFound = false;
      _isScanningActive = true;
    });
  }

  @override
  void dispose() {
    _scannerController.dispose(); // Release the hardware camera processes safely out of device memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      icon: const Icon(Icons.arrow_back, color: AppColors.textWhite, size: 20,),
                      onPressed: () {},
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8,),
                        const Text("GATE EXIT MODE", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 22,),
                      onPressed: _resetExitFields,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16,),

              // Camera scanner display module box wrapper
              Container(
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _isSessionFound ? AppColors.successGreen : AppColors.accentBlue,
                      width: 2.5
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onBarcodeDetected,
                      ),

                      if (_isScanningActive)
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.accentBlue.withOpacity(0.4), width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                      if (_isSessionFound)
                        Container(
                          color: Colors.black.withOpacity(0.75),
                          child: const Center(
                            child: Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 50,),
                          ),
                        )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24,),

              // Readout parameter displays
              const Text("Scanned Vehicle Number", style: TextStyle(color: AppColors.textMuted, fontSize: 14),),
              const SizedBox(height: 8,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  _scannedVehiclePlate,
                  style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20,),

              // Dual horizontal info panel split matrix rows
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Released Bay", style: TextStyle(color: AppColors.textMuted, fontSize: 14),),
                        const SizedBox(height: 8,),
                        Container(
                          padding: const EdgeInsets.all(18),
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(_scannedParkingBay, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Duration", style: TextStyle(color: AppColors.textMuted, fontSize: 14),),
                        const SizedBox(height: 8,),
                        Container(
                          padding: const EdgeInsets.all(18),
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(_totalDurationText, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20,),

              // Outward display calculation balance pane
              const Text("Total Outstanding Fees", style: TextStyle(color: AppColors.textMuted, fontSize: 14),),
              const SizedBox(height: 8,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  _calculatedParkingFee,
                  style: TextStyle(
                      color: _isSessionFound ? Colors.orangeAccent : AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),

              const SizedBox(height: 40,),

              // Master collection control action submission hook layout
              Container(
                width: double.infinity,
                height: 54,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _isSessionFound ? AppColors.successGreen : AppColors.textMuted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextButton(
                  onPressed: !_isSessionFound ? null : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Payment Collected. Session closed successfully!")),
                    );
                    _resetExitFields();
                  },
                  child: const Text("COLLECT PAYMENT & CLOSE SESSION", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16 ),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}