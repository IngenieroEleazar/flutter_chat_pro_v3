// lib/main.dart
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/authentication/landing_screen.dart';
import 'package:flutter_chat_pro/authentication/login_screen.dart';
import 'package:flutter_chat_pro/authentication/opt_screen.dart';
import 'package:flutter_chat_pro/authentication/user_information_screen.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/firebase_options.dart';
import 'package:flutter_chat_pro/main_screen/chat_screen.dart';
import 'package:flutter_chat_pro/main_screen/home_screen.dart';
import 'package:flutter_chat_pro/main_screen/profile_screen.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_pro/authentication/onboarding_screen.dart'; // Importa el onboarding screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(savedThemeMode: savedThemeMode, seenOnboarding: seenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode, required this.seenOnboarding});

  final AdaptiveThemeMode? savedThemeMode;
  final bool seenOnboarding;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Chat Pro',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: seenOnboarding ? Constants.landingScreen : Constants.onboardingScreen,
        routes: {
          Constants.onboardingScreen: (context) => const OnboardingScreen(),
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OTPScreen(),
          Constants.userInformationScreen: (context) => const UserInformationScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
        },
      ),
    );
  }
}