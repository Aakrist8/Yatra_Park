class UserProfile {
  final String name;
  final String email;
  final String? scannedVehicleNumber;

  UserProfile({
    required this.name,
    required this.email,
    this.scannedVehicleNumber,
  });
}