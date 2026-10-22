import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:civic_issue_reporter/l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'screens/splash_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'styles/app_theme.dart';
import 'providers/reports_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'utils/page_transitions.dart';

class CivicIssueReporterApp extends StatelessWidget {
  const CivicIssueReporterApp({super.key});

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return CustomPageTransitions.fade(const SplashScreen(),
            settings: settings);
      case '/language':
        return CustomPageTransitions.slideFromRight(
            const LanguageSelectionScreen(),
            settings: settings);
      case '/login':
        return CustomPageTransitions.fade(const LoginScreen(),
            settings: settings);
      case '/':
        // Root is AuthWrapper - The Gatekeeper
        return CustomPageTransitions.fade(const AuthWrapper(),
            settings: settings);
      case '/dashboard':
        // Protected Route
        return CustomPageTransitions.scale(
            const AuthWrapper(child: DashboardScreen()),
            settings: settings);
      case '/reports':
        return CustomPageTransitions.slideFromRight(
            const AuthWrapper(child: ReportsScreen()),
            settings: settings);
      case '/profile':
        return CustomPageTransitions.slideFromLeft(
            const AuthWrapper(child: ProfileScreen()),
            settings: settings);
      case '/chatbot':
        return CustomPageTransitions.slideFromRight(
            const AuthWrapper(child: ChatbotScreen()),
            settings: settings);
      case '/settings':
        return CustomPageTransitions.slideFromRight(
            const AuthWrapper(child: SettingsScreen()),
            settings: settings);
      case '/forgot-password':
        return CustomPageTransitions.slideFromRight(
            const ForgotPasswordScreen(),
            settings: settings);
      default:
        return MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
          settings: settings,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer2<AuthProvider, SettingsProvider>(
        builder: (context, authProvider, settings, _) {
          return MaterialApp(
            title: 'Civic Issue Reporter',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('te'), // Telugu
              Locale('kn'), // Kannada
            ],
            onGenerateRoute: _generateRoute,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.fontScale),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final Widget? child;
  const AuthWrapper({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    // We access AuthProvider via Provider to get the stream
    // IMPORTANT: listen: false here is okay because we are using StreamBuilder
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return child ?? const DashboardScreen();
      },
    );
  }
}
