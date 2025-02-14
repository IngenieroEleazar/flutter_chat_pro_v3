// lib/authentication/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_pro/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    OnboardingPage(
      image: 'assets/images/onboarding3.png',
      title: 'Bienvenido a B&V',
      description: 'Moldea tu futuro con nuestra aplicación de chat.',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding2.png',
      title: 'Chat en Tiempo Real',
      description: 'Conéctate con tus amigos y colegas en tiempo real.',
    ),
    OnboardingPage(
      image: 'assets/images/onboarding1.png',
      title: 'seguridad en tiempo real',
      description: 'Ajusta la aplicación a tus preferencias y necesidades.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: _currentPage == _pages.length - 1
                ? FloatingActionButton(
              onPressed: () async {
                // Guardar el estado de que el onboarding ya fue visto
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seenOnboarding', true);

                // Navegar al login screen
                Navigator.pushReplacementNamed(context, Constants.loginScreen);
              },
              child: Icon(Icons.arrow_forward),
            )
                : Container(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _pages.length; i++) {
      indicators.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return indicators;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.deepPurple : Colors.grey,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 200.0),
          SizedBox(height: 20.0),
          Text(
            title,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}