import 'package:flutter/material.dart';
import '../styles/app_theme.dart';

class Language {
  final String code;
  final String name;
  final String nativeName;

  Language({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? selectedLanguage;

  final List<Language> languages = [
    Language(code: 'en', name: 'English', nativeName: 'English'),
    Language(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
    Language(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    Language(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    Language(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    Language(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      selectedLanguage = languageCode;
    });
    
    // Delay navigation to show selection animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
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
              AppTheme.neutral200,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.language,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Select Your Language',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutral800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      const Text(
                        'Choose your preferred language to continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.neutral600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Language Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: languages.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemBuilder: (context, index) {
                        final language = languages[index];
                        final isSelected = selectedLanguage == language.code;
                        
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () => _selectLanguage(language.code),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected 
                                      ? AppTheme.primaryColor
                                      : AppTheme.neutral300,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: isSelected ? 12 : 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Language Icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : AppTheme.neutral300,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        language.code.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.neutral600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 16),
                                  
                                  // Language Names
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          language.nativeName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : AppTheme.neutral800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                        Text(
                          language.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.neutral600,
                          ),
                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Selection Indicator
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: isSelected ? 1.0 : 0.0,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.neutral100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.neutral300,
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppTheme.neutral600,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can change your language preference anytime in settings.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.neutral600,
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
    );
  }
}