import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/main_screen/my_chats_screen.dart';
import 'package:flutter_chat_pro/main_screen/teachers_screen.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> pages = const [
    MyChatsScreen(),
    TeachersScreen(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      // user comes back to the app
      // update user status to online
        context.read<AuthenticationProvider>().updateUserStatus(
          value: true,
        );
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      // app is inactive, paused, detached or hidden
      // update user status to offline
        context.read<AuthenticationProvider>().updateUserStatus(
          value: false,
        );
        break;
      default:
      // handle other states
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_moldea.png',
          height: 100, // Ajusta la altura según sea necesario
        ),
        backgroundColor: const Color(0xFF084EA5), // Color #084ea5
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: userImageWidget(
              imageUrl: authProvider.userModel!.image,
              radius: 20,
              onTap: () {
                // navigate to user profile with uis as arguments
                Navigator.pushNamed(
                  context,
                  Constants.profileScreen,
                  arguments: authProvider.userModel!.uid,
                );
              },
            ),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Docentes',
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: Colors.white, // Color de ítem seleccionado
        unselectedItemColor: Colors.white.withOpacity(0.6), // Color de ítems no seleccionados
        backgroundColor: const Color(0xFF084EA5), // Fondo del BottomNavigationBar
        onTap: (index) {
          // animate to the page
          pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}