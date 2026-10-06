import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/trading_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSignUp = false; // Toggle between Login mode and New Sign Up mode

  // Login Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // New Sign Up Additional Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid Gmail address.';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    TradingService().loginWithFirestoreVerification(
      email: email,
      password: password,
      onComplete: (success, error) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          widget.onLoginSuccess();
        } else {
          setState(() {
            _errorMessage = error ?? 'Account not found in Firestore. Please click "Signup for Kite" to register first.';
          });
        }
      },
    );
  }

  void _handleSignUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid Gmail address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    TradingService().createAccountAndLogin(
      email: email,
      password: password,
      fullName: name.isNotEmpty ? name : email.split('@')[0],
      phone: phone.isNotEmpty ? phone : '+91 98765 43210',
      onComplete: (success, error) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          widget.onLoginSuccess();
        } else {
          setState(() {
            _errorMessage = error ?? 'Failed to create account in Firestore.';
          });
        }
      },
    );
  }

  void _showForgotPasswordDialog() {
    final resetController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KiteTheme.panelBg,
        title: const Text('Reset Password', style: TextStyle(color: KiteTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your Gmail address to receive password reset instructions:', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: resetController,
              style: const TextStyle(color: KiteTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'user@gmail.com',
                hintStyle: const TextStyle(color: KiteTheme.textMuted),
                filled: true,
                fillColor: KiteTheme.darkBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: KiteTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset link sent to ${resetController.text.isNotEmpty ? resetController.text : "your Gmail"}!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: KiteTheme.zerodhaOrange),
            child: const Text('Send Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiteTheme.darkBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Zerodha Brand Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: KiteTheme.zerodhaOrange,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: KiteTheme.zerodhaOrange.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'K',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'KITE',
                    style: TextStyle(
                      color: KiteTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Simple Login / Sign Up Card Container
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: KiteTheme.panelBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KiteTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignUp ? 'Create New Account' : 'Login to Kite',
                      style: const TextStyle(
                        color: KiteTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp ? 'Save credentials directly to Firestore' : 'Access stocks, derivatives, mutual funds & IPOs',
                      style: const TextStyle(color: KiteTheme.textMuted, fontSize: 13),
                    ),

                    const SizedBox(height: 24),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: KiteTheme.redBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: KiteTheme.red.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: KiteTheme.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: KiteTheme.red, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_isSignUp) ...[
                      // Additional Name field for Sign Up
                      const Text('Full Name', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: 'e.g. Kirthish Shetty',
                          hintStyle: const TextStyle(color: KiteTheme.textMuted),
                          prefixIcon: const Icon(Icons.person_outline, color: KiteTheme.textSecondary, size: 20),
                          filled: true,
                          fillColor: KiteTheme.darkBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: KiteTheme.border)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Field 1: Gmail Address
                    const Text('User Gmail', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'user@gmail.com',
                        hintStyle: const TextStyle(color: KiteTheme.textMuted),
                        prefixIcon: const Icon(Icons.email_outlined, color: KiteTheme.textSecondary, size: 20),
                        filled: true,
                        fillColor: KiteTheme.darkBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: KiteTheme.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: KiteTheme.kiteBlue)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Field 2: User Password
                    const Text('User Password', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '••••••••••••',
                        hintStyle: const TextStyle(color: KiteTheme.textMuted),
                        prefixIcon: const Icon(Icons.lock_outline, color: KiteTheme.textSecondary, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: KiteTheme.textSecondary, size: 18),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: KiteTheme.darkBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: KiteTheme.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: KiteTheme.kiteBlue)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Main Action Button (Login or Create Account)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isSignUp ? _handleSignUp : _handleLogin),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KiteTheme.zerodhaOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                _isSignUp ? 'Create Account in Firestore' : 'Login',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer Options: Forgot password (Left) & New Sign up (Right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: _showForgotPasswordDialog,
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: KiteTheme.kiteBlue, fontSize: 13),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _errorMessage = null;
                            });
                          },
                          child: Text(
                            _isSignUp ? 'Login to Kite' : 'Signup for Kite',
                            style: const TextStyle(
                              color: KiteTheme.zerodhaOrange,
                              fontSize: 13,
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

              const SizedBox(height: 24),
              const Text(
                'Kite Broking Ltd.',
                style: TextStyle(color: KiteTheme.textMuted, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
