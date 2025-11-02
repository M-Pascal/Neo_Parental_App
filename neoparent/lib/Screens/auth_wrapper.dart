import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'welcome_screen.dart';
import 'main_navigation_screen.dart';

/// Authentication wrapper that redirects based on auth state
///
/// Automatically navigates users to the appropriate screen:
/// - Logged in users → Main app screen
/// - Logged out users → Welcome/Login screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate based on authentication state
        if (authProvider.isAuthenticated) {
          return const MainNavigationScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
