import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import 'login_screen.dart';

/// Welcome/Splash screen - First screen users see
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App title
                const Text(
                  AppStrings.welcomeTitle,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Lottie animation
                Lottie.asset(
                  'assets/Pediatrics.json',
                  width: 300,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.baby_changing_station,
                      size: 100,
                      color: AppColors.white,
                    );
                  },
                ),

                const SizedBox(height: 10),

                // App description
                const SizedBox(
                  width: 300,
                  child: Text(
                    AppStrings.welcomeDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Get Started button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      AppStrings.getStarted,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
