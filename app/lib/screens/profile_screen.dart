import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:ui';
import '../widgets/bottom_nav_widget.dart';
import '../styles/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../models/report.dart';
import '../widgets/top_accent_strip.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 2;
  bool _isEditing = false;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    final authProvider = context.read<AuthProvider>();
    _nameController = TextEditingController(text: authProvider.userName);
    _emailController = TextEditingController(text: authProvider.userEmail);
    _phoneController = TextEditingController(text: authProvider.userPhone);
    _addressController = TextEditingController(text: authProvider.userAddress);
    _bioController = TextEditingController(text: authProvider.userBio);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileData() async {
    final authProvider = context.read<AuthProvider>();

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    await authProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      bio: _bioController.text.trim(),
    );

    setState(() {
      _isEditing = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushNamed(context, '/reports');
        break;
      case 2:
        // Already on profile
        break;
      case 3:
        Navigator.pushNamed(context, '/chatbot');
        break;
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6), // Increased spacing
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: AppTheme.neutral200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.neutral800, // Dark text usage
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutral500,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ReportsProvider>(
      builder: (context, authProvider, reportsProvider, _) {
        // Calculate stats
        final reports = reportsProvider.reports;
        final totalFiled = reports.length;
        final resolved =
            reports.where((r) => r.status == ReportStatus.resolved).length;
        // Pending includes Sent and Received (active but not resolved)
        final pending = reports
            .where((r) =>
                r.status == ReportStatus.sent ||
                r.status == ReportStatus.received)
            .length;

        return Scaffold(
          extendBody: true,
          body: Container(
            color: AppTheme.neutral200,
            child: Column(
              children: [
                const SafeArea(
                  bottom: false,
                  child: TopAccentStrip(),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 320,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Blurred Background
                              ImageFiltered(
                                imageFilter:
                                    ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Container(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  child: _profileImage != null
                                      ? Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(color: AppTheme.neutral200),
                                ),
                              ),
                              // Profile Content
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 60),
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 4,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryColor
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            radius: 60,
                                            backgroundColor: Colors.white,
                                            backgroundImage:
                                                _profileImage != null
                                                    ? FileImage(_profileImage!)
                                                    : null,
                                            child: _profileImage == null
                                                ? const Icon(
                                                    Icons.person_rounded,
                                                    size: 60,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  )
                                                : null,
                                          ),
                                        ),
                                        if (_isEditing)
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: _pickProfileImage,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      authProvider.userName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.neutral900,
                                          ),
                                    ),
                                    Text(
                                      authProvider.userEmail,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.neutral600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          if (!_isEditing)
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: CircleAvatar(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.5),
                                child: IconButton(
                                  icon: const Icon(Icons.edit_rounded,
                                      color: AppTheme.primaryColor),
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true;
                                    });
                                  },
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.errorColor
                                        .withValues(alpha: 0.1),
                                    child: IconButton(
                                      icon: const Icon(Icons.close_rounded,
                                          color: AppTheme.errorColor),
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = false;
                                          _initializeControllers();
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor: AppTheme.primaryColor,
                                    child: IconButton(
                                      icon: const Icon(Icons.check_rounded,
                                          color: Colors.white),
                                      onPressed: _saveProfileData,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats Row
                                Row(
                                  children: [
                                    _buildStatCard(
                                      'Reports Filed',
                                      '$totalFiled',
                                      AppTheme.primaryColor,
                                      Icons.assignment_rounded,
                                    ),
                                    _buildStatCard(
                                      'Resolved',
                                      '$resolved',
                                      AppTheme.secondaryColor,
                                      Icons.check_circle_rounded,
                                    ),
                                    _buildStatCard(
                                      'Pending',
                                      '$pending',
                                      AppTheme.warningColor,
                                      Icons.pending_actions_rounded,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.neutral800,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                    'Full Name',
                                    Icons.person_outline_rounded,
                                    _nameController),
                                _buildTextField('Email Address',
                                    Icons.email_outlined, _emailController),
                                _buildTextField('Phone Number',
                                    Icons.phone_outlined, _phoneController),
                                _buildTextField(
                                    'Address',
                                    Icons.location_on_outlined,
                                    _addressController),
                                _buildTextField('Bio',
                                    Icons.info_outline_rounded, _bioController,
                                    maxLines: 3),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavWidget(
            currentIndex: _currentIndex,
            onTap: _onBottomNavTap,
          ),
        );
      },
    );
  }
}
