import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Hook up Supabase
import 'package:yatra_park/core/constants/app_colors.dart';
import 'package:yatra_park/core/services/supabase_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(); // 🧠 Controller for full name
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();

      // Real Supabase User Account Generation Query mapping
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: _passwordController.text,
        data: {'name': name}, // 🧠 Save name directly to Auth User Metadata
      );

      if (response.user != null && mounted) {
        // Pass name to your database service
        await SupabaseService().createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: name, // 🧠 Make sure your SupabaseService accepts name
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully! Returning to sign in screen."),
            backgroundColor: AppColors.successGreen,
          ),
        );
        // Pop back directly down to the primary login window stack sequence
        Navigator.pop(context);
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An unexpected execution issue occurred."), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentBlue.withOpacity(0.2), width: 2),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: AppColors.accentBlue,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Register a new operational terminal profile",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🧠 Full Name Input Field
                  const Text("Full Name", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return "Please enter your full name";
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceDark,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20),
                      hintText: "John Doe",
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Email Address", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter an email address";
                      if (!value.contains('@') || !value.contains('.')) return "Please enter a valid email address";
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceDark,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20),
                      hintText: "example@yatrapark.com",
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Password", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordHidden,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter a password";
                      if (value.length < 6) return "Password must be at least 6 characters long";
                      return null;
                    },
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
                      hintText: "Type your password",
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Confirm Password", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _isConfirmPasswordHidden,
                    style: const TextStyle(color: AppColors.textWhite, fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please confirm your password";
                      if (value != _passwordController.text) return "Passwords do not match";
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceDark,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                          });
                        },
                      ),
                      hintText: "Retype your password",
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 36),

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
                      onPressed: _isLoading ? null : _handleSignUp,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2),
                      )
                          : const Text(
                        "REGISTER PROFILE",
                        style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Drop back cleanly to LoginScreen container viewport
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(color: AppColors.accentBlue, fontSize: 14, fontWeight: FontWeight.bold),
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