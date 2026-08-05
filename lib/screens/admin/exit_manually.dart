import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 👈 Added Supabase client
import 'package:yatra_park/core/constants/app_colors.dart';
import 'package:yatra_park/screens/admin/admin_dashboard.dart';

class GateEntryScreen extends StatefulWidget {
  const GateEntryScreen({super.key});

  @override
  State<GateEntryScreen> createState() => _GateEntryScreenState();
}

class _GateEntryScreenState extends State<GateEntryScreen> {
  final _supabase = Supabase.instance.client;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isSaving = false;

  // Controllers for text field text capture parameters
  final TextEditingController _vehicleNumberController = TextEditingController(text: "BA 2 CH 1234");
  final TextEditingController _driverNameController = TextEditingController(); // 👈 Added Name Controller

  String _selectedBay = "Bay: A12";

  @override
  void initState() {
    super.initState();
    _initializeDefaultCamera();
  }

  void _initializeDefaultCamera() async {
    final mainCameras = await availableCameras();
    if (mainCameras.isNotEmpty) {
      _cameraController = CameraController(
        mainCameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isCameraInitialized = true;
        });
      }).catchError((Object e) {
        if (e is CameraException) {
          debugPrint('Camera initialization failed: ${e.description}');
        }
      });
    }
  }

  // 👈 New method that saves the transaction row into your database before dialog pop-up
  Future<String?> _insertParkingSession() async {
    try {
      final vehiclePlate = _vehicleNumberController.text.trim();
      final driverName = _driverNameController.text.trim();

      // Look up a fallback or target user account ID to assign the session data row
      final targetUser = _supabase.auth.currentUser?.id;
      if (targetUser == null) throw "No authorized user session active.";

      final response = await _supabase.from('parking_sessions').insert({
        'user_id': targetUser,
        'vehicle_plate': vehiclePlate,
        'driver_name': driverName.isNotEmpty ? driverName : "Guest Driver", // Fallback text safely matching structural type boundaries
        'assigned_bay': _selectedBay,
        'status': 'active',
        'entry_time': DateTime.now().toIso8601String(),
        'current_fare': 60.0, // Starting first hour base rate cost parameters
      }).select('id').single();

      return response['id'] as String; // Returns the generated session UUID row key block
    } catch (e) {
      debugPrint("Database Insertion Failure: $e");
      return null;
    }
  }

  void _processAndOpenTicket() async {
    if (_driverNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter driver name before initiating session"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() { _isSaving = true; });
    final String? databaseSessionId = await _insertParkingSession();
    setState(() { _isSaving = false; });

    if (databaseSessionId != null) {
      _showQrCodeDialog(databaseSessionId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error communicating with remote storage engine."), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showQrCodeDialog(String sessionId) {
    final String vehiclePlate = _vehicleNumberController.text.trim();
    final String driverName = _driverNameController.text.trim();

    // 👈 IMPORTANT: The QR data is now strictly the unique database row tracking ID!
    // This allows the exit gate reader to run an immediate matching query.
    final String qrPayloadString = sessionId;

    showDialog(
        context: context,
        barrierDismissible: false, // Force user to use button to secure flow steps integrity
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("GATE ENTRY TICKET", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  const SizedBox(height: 16),

                  Text("Name : $driverName", style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text("Plate : $vehiclePlate", style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text("Location : $_selectedBay", style: TextStyle(color: AppColors.textMuted.withOpacity(0.8), fontSize: 13)),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: qrPayloadString,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close Dialog view window
                        _driverNameController.clear(); // Wipe clear to reset state structures
                      },
                      child: const Text("DONE & PRINT", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      await _cameraController!.takePicture();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plate frame saved to temporary cache storage")),
      );
    } catch (e) {
      debugPrint("Error capturing image : $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _vehicleNumberController.dispose();
    _driverNameController.dispose(); // Clean release parameter memory blocks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView( // Added scroll layout view support to avoid keyboard layout bounds clipping errors
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
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardScreen())
                        );
                      },
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "GATE ENTRY MODE",
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: AppColors.textMuted, size: 22),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Camera Layout
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentBlue, width: 2.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _isCameraInitialized
                          ? AspectRatio(
                        aspectRatio: _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      )
                          : const CircularProgressIndicator(color: AppColors.accentBlue),
                      Positioned(
                        bottom: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: AppColors.accentBlue,
                          onPressed: _takePicture,
                          child: const Icon(Icons.camera_alt_rounded, color: AppColors.textWhite),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 👈 NEW FIELD 1: DRIVER NAME
              const Text("Driver Name", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _driverNameController,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  hintText: "Enter full name",
                  hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.3)),
                  contentPadding: const EdgeInsets.all(18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // FIELD 2: VEHICLE NUMBER
              const Text("Vehicle Number", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _vehicleNumberController,
                style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  contentPadding: const EdgeInsets.all(18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ASSIGNED PARKING BAY
              const Text("Assigned Parking Bay", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBay,
                    dropdownColor: AppColors.surfaceDark,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                    items: <String>['Bay: A12', 'Bay: B04', 'Bay: C09', 'Bay: D15'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedBay = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // MASTER ACTION TRIGGER BUTTON
              Container(
                width: double.infinity,
                height: 54,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: TextButton(
                  onPressed: _isSaving ? null : _processAndOpenTicket,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: AppColors.textWhite)
                      : const Text("START SESSION & GENERATE QR", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}