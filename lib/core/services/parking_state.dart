import 'package:flutter/material.dart';
import 'package:yatra_park/core/services/parking_repository.dart';

class ParkingState extends ChangeNotifier {
  final ParkingRepository _repository = ParkingRepository();

  final int totalBays = 50;
  int _occupiedBays = 0;

  int get occupiedBays => _occupiedBays;

  /// Computed property to calculate available spaces automatically
  int get availableBays => totalBays - _occupiedBays;

  /// Expose repository fare calculation helper
  double calculateFare(dynamic entryTime) => _repository.calculateOutstandingFare(entryTime);

  /// Synchronize occupied bay count live from Supabase
  Future<void> syncOccupancyFromDatabase() async {
    final count = await _repository.fetchActiveOccupancyCount();
    _occupiedBays = count;
    notifyListeners();
  }

  /// Increments vehicle count when a car enters
  void checkInVehicle() {
    if (_occupiedBays < totalBays) {
      _occupiedBays++;
      notifyListeners();
    }
  }

  /// Completes checkout in DB and decrements vehicle count
  Future<bool> checkOutVehicle(String sessionId, dynamic entryTime) async {
    final double finalFare = _repository.calculateOutstandingFare(entryTime);
    final bool success = await _repository.closeActiveSession(sessionId, finalFare);

    if (success) {
      if (_occupiedBays > 0) {
        _occupiedBays--;
      }
      notifyListeners();
    }
    return success;
  }
}

// Global instance variable accessible app-wide
final parkingState = ParkingState();