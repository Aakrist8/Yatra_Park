import 'package:flutter/material.dart';
import 'package:yatra_park/core/constants/app_theme.dart';
import 'package:yatra_park/models/user_profile.dart';
import 'package:yatra_park/screens/admin/admin_dashboard.dart';
import 'package:yatra_park/screens/admin/exit_manually.dart';
import 'package:yatra_park/screens/admin/gate_entry_screen.dart';
import 'package:yatra_park/screens/admin/gate_exit_screen.dart';
import 'package:yatra_park/screens/admin/record.dart';
import 'package:yatra_park/screens/user/booking_history.dart';
import 'package:yatra_park/screens/user/payment_success.dart';
import 'package:yatra_park/screens/user/profile_page.dart';
import 'package:yatra_park/screens/user/user_dashboard.dart';
import 'screens/auth/login_page.dart';
import 'screens/user/user_home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yatra_park/core/services/supabase_service.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://hwqwkxfzhfyvuezrfnaz.supabase.co",
        anonKey: "sb_publishable_IMFUaKdn50-2n2VbDSA0Cw_d13z6LdH",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: LoginScreen()
      );

  }
}