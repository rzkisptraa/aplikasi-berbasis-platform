import 'package:flutter/material.dart';
import '../../storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Smooth Fade-in animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();
    checkSession();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> checkSession() async {
    // Artificial duration to show beautiful branding
    await Future.delayed(const Duration(seconds: 3));

    final token = await SecureStorage.getToken();
    final role = await SecureStorage.getRole();

    if (!mounted) return;

    if (token == null || role == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (role == 'seller') {
      Navigator.pushReplacementNamed(context, '/seller-home');
    } else if (role == 'courier') {
      Navigator.pushReplacementNamed(context, '/courier-home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.recycling, 
                size: 110, 
                color: Colors.white
              ),
              SizedBox(height: 20),
              Text(
                'EcoTrash',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ubah Sampah Jadi Berkah',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 60),
              CircularProgressIndicator(
                color: Colors.white70,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
