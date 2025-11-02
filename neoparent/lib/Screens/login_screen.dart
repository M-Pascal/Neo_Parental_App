import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/common_widgets.dart';
import 'register_screen.dart';
import 'main_navigation_screen.dart';

/// Login screen with Provider state management
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      showSnackBar(context, AppStrings.agreeToTermsRequired, isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      showSnackBar(context, AppStrings.loginSuccessful);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      showSnackBar(
        context,
        authProvider.errorMessage ?? AppStrings.loginFailed,
        isError: true,
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.resetPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a password reset link.'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              labelText: AppStrings.email,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.sendResetLink),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendPasswordResetEmail(
        emailController.text.trim(),
      );

      if (mounted) {
        showSnackBar(
          context,
          success
              ? AppStrings.passwordResetEmailSent
              : authProvider.errorMessage ?? 'Failed to send reset email',
          isError: !success,
        );
      }
    }
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header
                      _buildHeader(context),

                      // Form
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              _buildForm(),
                              const Spacer(),
                              _buildCopyright(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Welcome\nto\nNeoParental',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              const Text(
                AppStrings.loginTitle,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            labelText: AppStrings.email,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return AppStrings.invalidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _passwordController,
            labelText: AppStrings.password,
            prefixIcon: Icons.lock_outlined,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return AppStrings.passwordTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: const Text(
                AppStrings.forgotPassword,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) =>
                    setState(() => _agreeToTerms = value ?? false),
                activeColor: AppColors.primaryDark,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                  child: const Text(
                    AppStrings.agreeToTerms,
                    style: TextStyle(fontSize: 14, color: AppColors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: AppStrings.login,
            icon: Icons.login_rounded,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              const Text(
                AppStrings.dontHaveAccount,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  AppStrings.createNewAccount,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyright() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.0),
      child: Text(
        AppStrings.copyright,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
          letterSpacing: 0.9,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
