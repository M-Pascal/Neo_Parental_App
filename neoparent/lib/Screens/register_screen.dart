import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/common_widgets.dart';

/// Register screen with Provider state management
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      showSnackBar(context, AppStrings.agreeToTermsRequired, isError: true);
      return;
    }

    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
    final authProvider = context.read<AuthProvider>();

    // Sign up the user (no auto-login)
    final success = await authProvider.signUp(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: fullName,
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      showSnackBar(
        context,
        'Registration successful! Please login to continue.',
      );
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        // Navigate back to login screen
        Navigator.pop(context);
      }
    } else {
      showSnackBar(
        context,
        authProvider.errorMessage ?? AppStrings.registrationFailed,
        isError: true,
      );
    }
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
                      _buildHeader(context),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
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
                AppStrings.registerTitle,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
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
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _firstNameController,
                  labelText: AppStrings.firstName,
                  prefixIcon: Icons.person_outline,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _lastNameController,
                  labelText: AppStrings.lastName,
                  prefixIcon: Icons.person_outline,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _usernameController,
            labelText: AppStrings.username,
            hintText: 'Choose a unique username',
            prefixIcon: Icons.account_circle_outlined,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (value!.length < 3)
                return 'Username must be at least 3 characters';
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                return 'Only letters, numbers, and underscores allowed';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _phoneController,
            labelText: AppStrings.phoneNumber,
            hintText: '+250xxxxxxxxx',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              String clean = value.replaceAll(RegExp(r'[\s-]'), '');
              if (!clean.startsWith('+250')) return 'Must start with +250';
              if (clean.length != 13) return 'Invalid phone number';
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _addressController,
            labelText: AppStrings.homeAddress,
            hintText: 'District/Sector',
            prefixIcon: Icons.location_on_outlined,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _emailController,
            labelText: AppStrings.email,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value!)) {
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
              if (value?.isEmpty ?? true) return 'Required';
              if (value!.length < 6) return AppStrings.passwordTooShort;
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: AppStrings.confirmPassword,
            prefixIcon: Icons.lock_outlined,
            isPassword: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return AppStrings.passwordsDoNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 15),
          CustomButton(
            text: AppStrings.register,
            icon: Icons.person_add,
            onPressed: _handleRegister,
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              const Text(
                AppStrings.alreadyHaveAccount,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  AppStrings.signIn,
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
