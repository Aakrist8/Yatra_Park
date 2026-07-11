import 'package:flutter/material.dart';
import 'package:yatra_park/core/constants/app_colors.dart';
import 'package:yatra_park/screens/admin/admin_dashboard.dart';
import 'package:yatra_park/screens/user/user_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isLoading = false;

  // AUTHENTICATION LOGIC ENGINE
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate backend server latency delay
    await Future.delayed(const Duration(seconds: 1));

    final String username = _emailController.text.trim();
    final String password = _passwordController.text;

    setState(() {
      _isLoading = false;
    });

    // Role verification protocol based on the secret keys
    if (username == "admin" && password == "admin123") {
      _navigateToDashboard(role: "Admin");
    } else if (username == "staff" && password == "staff123") {
      _navigateToDashboard(role: "Staff");
    } else {
      // Show alert error if credentials fail validation checks
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Username or Password!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _navigateToDashboard({required String role}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Welcome back, $role!"),
        backgroundColor: AppColors.successGreen,
      ),
    );

    // Push replacement clears the login screen out of device memory stack
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BRAND LOGO INDICATOR ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentBlue.withOpacity(0.2), width: 2),
                      ),
                      child: const Icon(
                        Icons.local_parking_rounded,
                        color: AppColors.accentBlue,
                        size: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      "YATRA PARK",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  Center(
                    child: Text(
                      "Terminal Management Authentication",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- USERNAME TEXT FIELD ---
                  const Text("Email", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
                    validator: (value) => (value == null || value.isEmpty) ? "Please enter email" : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceDark,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20),
                      hintText: "Enter Emai",
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- PASSWORD TEXT FIELD ---
                  const Text("Password", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordHidden,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
                    validator: (value) => (value == null || value.isEmpty) ? "Please enter password" : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceDark,
                      prefixIcon: const Icon(Icons.lock_open_rounded, color: AppColors.textMuted, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordHidden = !_isPasswordHidden;
                          });
                        },
                      ),
                      hintText: "Enter Password",
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // --- AUTHENTICATION TRIGGER BUTTON ---
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2),
                      )
                          : const Text(
                        "SECURE SIGN IN",
                        style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 15),

                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- NEWLY ADDED SIGN UP PROMPT BUTTON ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have a terminal account? ",
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Hook navigation logic up to SignUpScreen terminal profile here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Redirecting to Signup Page...")),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


