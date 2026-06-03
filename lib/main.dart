import 'package:flutter/material.dart';
import 'package:yatra_park/core/constants/app_theme.dart';
import 'package:yatra_park/models/user_profile.dart';
import 'package:yatra_park/screens/admin/gate_entry_screen.dart';
import 'package:yatra_park/screens/admin/gate_exit_screen.dart';
import 'package:yatra_park/screens/user/booking_history.dart';
import 'package:yatra_park/screens/user/payment_success.dart';
import 'package:yatra_park/screens/user/profile_page.dart';
import 'package:yatra_park/screens/user/user_dashboard.dart';
import 'screens/auth/login_page.dart';
import 'screens/user/user_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: GateExitScreen(),
      );

  }
}