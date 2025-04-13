import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/main_screen/my_chats_screen.dart';
import 'package:flutter_chat_pro/main_screen/people_screen.dart';
import 'package:flutter_chat_pro/main_screen/teachers_screen.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> pages = const [
    MyChatsScreen(),
    PeopleScreen(),
    TeachersScreen(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final authProvider = context.read<AuthenticationProvider>();
    switch (state) {
      case AppLifecycleState.resumed:
        authProvider.updateUserStatus(value: true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        authProvider.updateUserStatus(value: false);
        break;
      case AppLifecycleState.hidden:
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthenticationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo_moldea.png',
          height: 70,
        ),
        elevation: 1,
        shadowColor: theme.shadowColor.withOpacity(0.1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                Constants.profileScreen,
                arguments: authProvider.userModel!.uid,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: authProvider.userModel?.image != null
                    ? NetworkImage(authProvider.userModel!.image)
                    : null,
                child: authProvider.userModel?.image == null
                    ? Icon(
                  Icons.person,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) => setState(() => currentIndex = index),
        children: pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            color: theme.dividerColor.withOpacity(0.2),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildMinimalistNavBar(theme),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildMinimalistNavBar(ThemeData theme) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.forum_outlined),
          activeIcon: Icon(Icons.forum),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'People',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Docentes',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      onTap: (index) => pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }
}