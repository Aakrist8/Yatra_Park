import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // 1. Create a custom profile record in our public table
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? fullName,
  }) async {
    try {
      await _client.from('profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName ?? email.split('@')[0], // Fallback to email prefix if blank
        'terminal_name': 'Terminal Hub Alpha',
        'role': 'operator',
      });
    } catch (e) {
      throw Exception('Failed to initialize user profile data: $e');
    }
  }

  // 2. Fetch profile data to display on the User Dashboard screen
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return data;
    } catch (e) {
      return null;
    }
  }
}