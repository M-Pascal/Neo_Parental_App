import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserProfileService _profileService = UserProfileService();

  // Text controllers for form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _childDobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _childDobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final profile = await _profileService.getUserProfile(
        authProvider.currentUser!.uid,
      );

      if (profile != null && mounted) {
        setState(() {
          _fullNameController.text = profile.fullName;
          _emailController.text = profile.email;
          _phoneController.text = profile.phoneNumber ?? '';
          _addressController.text = profile.address ?? '';
          _childDobController.text = profile.childDateOfBirth ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    try {
      await _profileService.updateUserProfile(authProvider.currentUser!.uid, {
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'childDateOfBirth': _childDobController.text.trim(),
      });

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Colored Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFD2691E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                bottom: 40,
              ),
              child: Column(
                children: [
                  // First line: Back button and Save button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      // Save button
                      TextButton(
                        onPressed: _isEditing ? _saveProfile : null,
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: _isEditing
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Second line: Profile Title
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Profile picture placeholder
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Edit and Cancel buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Edit button
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _isEditing = !_isEditing);
                        },
                        icon: Icon(
                          _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                          size: 18,
                          color: const Color(0xFFFF6B35),
                        ),
                        label: Text(
                          _isEditing ? 'Done Editing' : 'Edit Profile',
                          style: const TextStyle(
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF6B35),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                      ),

                      // Cancel button
                      ElevatedButton.icon(
                        onPressed: () {
                          _clearAllFields();
                        },
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Profile form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Full Name Field
                  _buildFormField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    hintText: 'Enter your full name',
                    enabled: _isEditing,
                  ),

                  const SizedBox(height: 20),

                  // Email Field
                  _buildFormField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    hintText: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    enabled: false, // Email should not be editable
                  ),

                  const SizedBox(height: 20),

                  // Phone Number Field
                  _buildFormField(
                    controller: _phoneController,
                    label: 'Telephone Number',
                    icon: Icons.phone_outlined,
                    hintText: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                  ),

                  const SizedBox(height: 20),

                  // Child Date of Birth Field
                  _buildDateField(
                    controller: _childDobController,
                    label: 'Child Date of Birth',
                    icon: Icons.cake_outlined,
                    hintText: 'Select child\'s date of birth',
                    enabled: _isEditing,
                  ),

                  const SizedBox(height: 20),

                  // Address Field
                  _buildFormField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    hintText: 'Enter your address',
                    maxLines: 3,
                    enabled: _isEditing,
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFFFF6B35), size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          onTap: enabled ? () => _selectDate() : null,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFFFF6B35), size: 20),
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Color(0xFFFF6B35),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Default to 1 year ago
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B35),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _childDobController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _clearAllFields() {
    if (_isEditing) {
      // Reload the profile to reset any unsaved changes
      _loadUserProfile();
      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes cancelled!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
