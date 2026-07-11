import 'package:flutter/material.dart';

class ParkingState extends ChangeNotifier {
  // Master configuration constants
  final int totalBays = 50;
  int occupiedBays = 36; // Initial starting point data seed

  // Computed property to calculate available spaces automatically
  int get availableBays => totalBays - occupiedBays;

  //  to increment vehicle count when a car enters
  void checkInVehicle() {
    if (occupiedBays < totalBays) {
      occupiedBays++;
      notifyListeners(); // 👈 This triggers all listening screens to refresh instantly
    }
  }

  // Method to decrement vehicle count when a car leaves
  void checkOutVehicle() {
    if (occupiedBays > 0) {
      occupiedBays--;
      notifyListeners(); // 👈 This triggers all listening screens to refresh instantly
    }
  }
}

// Global instance variable matrix so any file can access the exact same data data streams
final parkingState = ParkingState();