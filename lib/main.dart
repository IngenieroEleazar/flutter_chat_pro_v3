import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/authentication/landing_screen.dart';
import 'package:flutter_chat_pro/authentication/login_screen.dart';
import 'package:flutter_chat_pro/authentication/onboarding_screen.dart';
import 'package:flutter_chat_pro/authentication/opt_screen.dart';
import 'package:flutter_chat_pro/authentication/user_information_screen.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/firebase_options.dart';
import 'package:flutter_chat_pro/main_screen/chat_screen.dart';
import 'package:flutter_chat_pro/main_screen/friend_requests_screen.dart';
import 'package:flutter_chat_pro/main_screen/friends_screen.dart';
import 'package:flutter_chat_pro/main_screen/home_screen.dart';
import 'package:flutter_chat_pro/main_screen/profile_screen.dart';
import 'package:flutter_chat_pro/main_screen/teachers_screen.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/utilities/shared_preferences_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = !(prefs.getBool('onboarding_completed') ?? false);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MyApp(
        savedThemeMode: savedThemeMode,
        showOnboarding: showOnboarding,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.savedThemeMode,
    required this.showOnboarding,
  });

  final AdaptiveThemeMode? savedThemeMode;
  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 1,
          backgroundColor: Colors.white,
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey[600],
        ),
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 1,
          backgroundColor: Colors.grey[900],
          titleTextStyle: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.deepPurple[200],
          unselectedItemColor: Colors.grey[500],
        ),
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Chat Pro',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: showOnboarding
            ? Constants.onboardingScreen
            : Constants.landingScreen,
        routes: {
          Constants.onboardingScreen: (context) => const OnboardingScreen(),
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OTPScreen(),
          Constants.userInformationScreen: (context) => const UserInformationScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.friendsScreen: (context) => const FriendsScreen(),
          Constants.friendRequestsScreen: (context) => const FriendRequestScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
          Constants.teachersScreen: (context) => const TeachersScreen(),
        },
      ),
    );
  }
}