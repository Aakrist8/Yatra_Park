import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParkingRepository {
  final _supabase = Supabase.instance.client;

  /// Calculates progressive fare:
  /// NPR 60.00 for the first hour,
  /// NPR 30.00 for every additional hour (or part thereof).
  double calculateOutstandingFare(dynamic entryTimeInput) {
    if (entryTimeInput == null) return 60.0;

    DateTime entryTime;

    try {
      if (entryTimeInput is String) {
        String raw = entryTimeInput.trim();
        if (raw.isEmpty) return 60.0;

        String formatted = raw.replaceAll(' ', 'T');

        if (!formatted.endsWith('Z') && !formatted.contains('+')) {
          formatted += 'Z';
        }

        entryTime = DateTime.parse(formatted).toLocal();
      } else if (entryTimeInput is DateTime) {
        entryTime = entryTimeInput.toLocal();
      } else {
        return 60.0;
      }
    } catch (e) {
      debugPrint("Parsing entry time failed: $e");
      return 60.0;
    }

    final now = DateTime.now();
    final totalMinutes = now.difference(entryTime).inMinutes;

    // First hour
    if (totalMinutes <= 60) {
      return 60.0;
    }

    final remainingMinutes = totalMinutes - 60;
    final additionalHours = (remainingMinutes / 60).ceil();

    return 60.0 + (additionalHours * 30.0);
  }

  /// Marks an active parking session as completed.
  Future<bool> closeActiveSession(String sessionId, double finalFare) async {
    try {
      await _supabase.from('parking_sessions').update({
        'status': 'completed',
        'current_fare': finalFare,
      }).eq('id', sessionId);

      return true;
    } catch (e) {
      debugPrint("Repository error during exit check-out: $e");
      return false;
    }
  }

  /// Returns the total number of active parking sessions.
  Future<int> fetchActiveOccupancyCount() async {
    try {
      final response = await _supabase
          .from('parking_sessions')
          .select('id')
          .eq('status', 'active');

      return response.length;
    } catch (e) {
      debugPrint("Failed to fetch occupancy count: $e");
      return 0;
    }
  }
}
