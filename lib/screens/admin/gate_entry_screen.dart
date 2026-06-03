import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:yatra_park/core/constants/app_colors.dart';


class GateEntryScreen  extends StatefulWidget {
  const GateEntryScreen({super.key});


  @override
  State<GateEntryScreen> createState() => _GateEntryScreenState();
}

class _GateEntryScreenState extends State<GateEntryScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

// This controller captures whatever user types inside the box (if camera not good)
  final TextEditingController _vehicleNumberController = TextEditingController(text: "BA 2 CH 1234");

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
          print('Camera initialization failed: ${e.description}');
        }
      });
    }
  }

  void _showQrCodeDialog() {        //Read what is typed in
    final String vehiclePlate = _vehicleNumberController.text.trim();   //collect the current data values to pack inside a qr pattern string

    final String qrPayloadString = "Vehicle: $vehiclePlate | Position : $_selectedBay"; //combine vehicle and bay data together so scanner red both field once


    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("GATE ENTRY TICKET", style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.8),),
                  const SizedBox(height: 12,),




                  //show text confirm what database parameters are written


                  Text("Plate : $vehiclePlate", style: const TextStyle(color: AppColors.textWhite, fontSize: 15, fontWeight: FontWeight(500)),),


                  const SizedBox(height: 24,),




                  // Rendered qr from field values


                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: QrImageView(
                      data: qrPayloadString,        //Feeds whatever data entered
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),


                  const SizedBox(height: 24,),


                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: (){
                        //Here is where we will add our database save func later
                        //save to database
                        Navigator.pop(context);
                      },
                      child: const Text("SAVE & DONE", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),),
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
        const SnackBar(content: Text("Plate frame saved to temporary cache storage"),),
      );
    } catch (e) {
      debugPrint("Error capturing image : $e");
    }
  }


  @override
  void dispose() {
    _cameraController?.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
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
                    onPressed: () {

                    },
                  ),


                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.successGreen,shape: BoxShape.circle),
                      ),

                      const SizedBox(width: 8,),
                      const Text("GATE ENTRY MODE", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),),

                    ],
                  ),



                  IconButton(
                    icon: const Icon(Icons.info_outline, color: AppColors.textMuted, size: 22,),
                    onPressed: (){},
                  ),


                ],
              ),
            ),


            const SizedBox(height: 16,),


            //camera layout

            Container(
              width: double.infinity,
              height: 260,
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
                        ? AspectRatio (
                      aspectRatio : _cameraController!.value.aspectRatio,
                      child : CameraPreview(_cameraController!),
                    )
                        : const CircularProgressIndicator(color: AppColors.accentBlue,),


                    Positioned(
                      bottom: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: AppColors.accentBlue,
                        onPressed: _takePicture,
                        child: const Icon (Icons.camera_alt_rounded, color: AppColors.textWhite,),
                      ),
                    )
                  ],
                ),
              ),

            ),

            const SizedBox(height: 24,),


            //Editable input field


            const Text("Vehicle Number", style: TextStyle(color: AppColors.textMuted, fontSize: 14),),
            const SizedBox(height: 8,),
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


            const SizedBox(height: 20,),


            //ASSIGNEDD PARKING BAY


            const Text("Assigned Parking Bay", style: TextStyle(color: AppColors.textMuted, fontSize: 14),),
            const SizedBox(height: 8,),

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
                        _selectedBay = newValue; // Mutates dynamic dropdown configuration state tracking
                      });
                    }
                  },
                ),
              ),
            ),


            const SizedBox(height: 40,),

            //master database action

            Container(
              width: double.infinity,
              height: 54,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                borderRadius: BorderRadius.circular(28),
              ),

              child: TextButton(
                onPressed: _showQrCodeDialog,
                child: const Text("START SESSION & GENERATE QR", style: TextStyle(color: AppColors.textWhite, fontWeight:FontWeight.bold, fontSize: 16 ),),
              ),

            )



          ],
        ),
      ),
    );
  }


}