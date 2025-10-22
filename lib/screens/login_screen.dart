import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final List<OverlayEntry> _activeToasts = [];

  // Test credentials
  static const String _testEmail = 'admin@test.com';
  static const String _testPassword = 'admin123';

  @override
  void dispose() {
    // Remove all active toasts
    for (var entry in _activeToasts) {
      entry.remove();
    }
    _activeToasts.clear();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showCustomToast(String message) {
    // Maximum 2 toasts at a time - remove oldest (bottom) if limit reached
    if (_activeToasts.length >= 2) {
      final oldestToast = _activeToasts.first;
      oldestToast.remove();
      _activeToasts.removeAt(0);
    }

    final overlay = Overlay.of(context);
    final isSecondToast = _activeToasts.length == 1;
    
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)), // Slide up smoothly
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background stacked card (appears ABOVE and BEHIND the main card)
                if (isSecondToast)
                  Positioned(
                    bottom: 6, // Position slightly above
                    left: 9, // Narrower by 9px on each side
                    right: 9,
                    child: Container(
                      height: 51,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Main toast card (front)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/warning_icon.png',
                        width: 16,
                        height: 16,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFF0A0A0A),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0A0A0A),
                            height: 1.5,
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
    );

    overlay.insert(overlayEntry);
    _activeToasts.add(overlayEntry);

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_activeToasts.contains(overlayEntry)) {
        overlayEntry.remove();
        _activeToasts.remove(overlayEntry);
      }
    });
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Check if fields are empty
    if (email.isEmpty || password.isEmpty) {
      _showCustomToast('Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a brief delay for login
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (email == _testEmail && password == _testPassword) {
        // Successful login
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // Failed login
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD4A200), // #D4A200 at 0%
              Color(0xFFC48828), // #C48828 at 50%
              Color(0xFFD4AF37), // #D4AF37 at 100%
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: 362.32,
              constraints: const BoxConstraints(maxWidth: 362.32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 50,
                    offset: const Offset(0, 25),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 23.99),
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/admin_logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFD4A200),
                                  Color(0xFFC48828),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Title
                    const Text(
                      'Admin Panel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Subtitle
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 23.99),
                      child: Text(
                        'Sign in to manage your platform',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF717182),
                          height: 1.43,
                        ),
                      ),
                    ),
                    const SizedBox(height: 23.99),
                    // Email Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.99),
                      child: Container(
                        width: 314.34,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 12,
                              top: 14,
                              child: Image.asset(
                                'assets/images/mail_icon.png',
                                width: 20,
                                height: 20,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.email_outlined,
                                    size: 20,
                                    color: Color(0xFF717182),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 40, right: 12, top: 4, bottom: 4),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF717182),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'admin@example.com',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF717182),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  errorStyle: TextStyle(height: 0, fontSize: 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 11.99),
                    // Password Input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.99),
                      child: Container(
                        width: 314.34,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 12,
                              top: 14,
                              child: Image.asset(
                                'assets/images/lock_icon.png',
                                width: 20,
                                height: 20,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                    color: Color(0xFF717182),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 40, right: 40, top: 4, bottom: 4),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF717182),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Enter password',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF717182),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  errorStyle: TextStyle(height: 0, fontSize: 0),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 14,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Image.asset(
                                  'assets/images/eye_icon.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      size: 20,
                                      color: const Color(0xFF717182),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18.19),
                    // Forgot Password
                    Padding(
                      padding: const EdgeInsets.only(left: 23.99),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/reset-password');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFD4A200),
                              height: 1.43,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 17.99),
                    // Sign In Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.99),
                      child: Container(
                        width: 314.34,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFD4A200),
                              Color(0xFFC48828),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontFamily: 'Arial',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.43,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.01),
                    // Security Features
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.99),
                      child: Container(
                        width: 314.34,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black.withValues(alpha: 0.1),
                              width: 1.1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 17.09),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSecurityFeature('Secure login with session tracking'),
                            const SizedBox(height: 7.99),
                            _buildSecurityFeature('Role-based access control'),
                            const SizedBox(height: 7.99),
                            _buildSecurityFeature('Failed login attempts monitored'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 23.99),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityFeature(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7.99,
          height: 7.99,
          decoration: const BoxDecoration(
            color: Color(0xFF00C950),
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.only(top: 4),
        ),
        const SizedBox(width: 7.99),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Arial',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF717182),
              height: 1.33,
            ),
          ),
        ),
      ],
    );
  }
}
