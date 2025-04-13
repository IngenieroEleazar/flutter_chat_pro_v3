import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/app_bar_back_button.dart';
import 'package:flutter_chat_pro/widgets/profile_details_card.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    _loadTheme();
    super.initState();
  }

  Future<void> _loadTheme() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      _isDarkMode = savedThemeMode == AdaptiveThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarBackButton(),
        title: const Text('Perfil'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: context.read<AuthenticationProvider>().userStream(userID: uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar perfil'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel = UserModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
          );

          return _buildProfileContent(context, userModel);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel userModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ProfileDetailsCard(userModel: userModel),
          const SizedBox(height: 24),

          // Sección de Configuración
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Configuración',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),

          // Opciones
          _buildSettingsList(context),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        _buildListTile(
          icon: Icons.person_outline,
          title: 'Perfil',
          onTap: () {},
        ),
        const Divider(height: 1),

        _buildThemeSwitchTile(),
        const Divider(height: 1),

        _buildLogoutTile(context),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildThemeSwitchTile() {
    return ListTile(
      leading: Icon(
        _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
      ),
      title: const Text('Modo Oscuro'),
      trailing: Switch(
        value: _isDarkMode,
        onChanged: (value) {
          setState(() => _isDarkMode = value);
          value
              ? AdaptiveTheme.of(context).setDark()
              : AdaptiveTheme.of(context).setLight();
        },
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Cerrar Sesión',
        style: TextStyle(color: Colors.red),
      ),
      onTap: () => _showLogoutDialog(context),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showMyAnimatedDialog(
      context: context,
      title: 'Cerrar Sesión',
      content: '¿Estás seguro que deseas cerrar sesión?',
      textAction: 'Cerrar Sesión',
      onActionTap: (value) {
        if (value) {
          context.read<AuthenticationProvider>().logout().whenComplete(() {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              Constants.loginScreen,
                  (route) => false,
            );
          });
        }
      },
    );
  }
}