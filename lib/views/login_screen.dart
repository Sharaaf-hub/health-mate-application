import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../controllers/health_provider.dart';
import 'package:provider/provider.dart';

import '../database/database_helper.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await DatabaseHelper.instance.loginUser(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password.'),
          ),
        );
        return;
      }

      final int userId = user['id'] as int;

      if (!mounted) return;

      await context.read<HealthProvider>().setUserId(userId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(userId: userId),
        ),
      );
    } on DatabaseException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A database error occurred. Please try again.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to log in. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EEE7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 12,
                      sigmaY: 12,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDEBDD).withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.75),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF245640)
                                .withValues(alpha: 0.12),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Mountain Header.
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            child: SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/images/healthmate_mountain_header.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    color: const Color(0xFF2D5240)
                                        .withValues(alpha: 0.55),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 58,
                                              width: 58,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(17),
                                              ),
                                              child: const Icon(
                                                Icons.favorite,
                                                color: Color(0xFF2D5240),
                                                size: 34,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Flexible(
                                              child: Text(
                                                'HealthMate',
                                                style: TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Your daily companion for a healthier life.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Login Form.
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 28,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF245640),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                const Text(
                                  'Log in to continue your health journey.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF52665B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Container(
                                  height: 4,
                                  width: 65,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF568568),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // Email Address.
                                const Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF245640),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF34483D),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your email address',
                                    hintStyle: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF858D87),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFF568568),
                                      size: 23,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF3F8F3)
                                        .withValues(alpha: 0.85),
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD2E1D3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF568568),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Password.
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF245640),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextField(
                                  controller: passwordController,
                                  obscureText: hidePassword,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF34483D),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF858D87),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFF568568),
                                      size: 23,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          hidePassword = !hidePassword;
                                        });
                                      },
                                      icon: Icon(
                                        hidePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF777777),
                                        size: 22,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF3F8F3)
                                        .withValues(alpha: 0.85),
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD2E1D3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF568568),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // Login Button.
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF245640),
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(13),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 9),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 21,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 3),

                                // Sign Up Footer.
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 4,
                                      children: [
                                        const Text(
                                          "Don't have an account?",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF52665B),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SignupScreen(),
                                                    ),
                                                  );
                                                },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 8,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF245640),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}