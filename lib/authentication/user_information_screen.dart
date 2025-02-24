import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/app_bar_back_button.dart';
import 'package:flutter_chat_pro/widgets/display_user_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);
  File? finalFileImage;
  String userImage = '';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _dniController.addListener(_validateForm);
    _correoController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _correoController.dispose();
    _isButtonEnabled.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isNameValid = _nameController.text.isNotEmpty && _nameController.text.length >= 3;
    final isDniValid = _dniController.text.isNotEmpty;
    final isCorreoValid = _correoController.text.isNotEmpty;
    _isButtonEnabled.value = isNameValid && isDniValid && isCorreoValid;
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );

    // crop image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      }
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                selectImage(true);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
            ),
            ListTile(
              onTap: () {
                selectImage(false);
              },
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text('User Information'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              DisplayUserImage(
                finalFileImage: finalFileImage,
                radius: 60,
                onPressed: () {
                  showBottomSheet();
                },
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _dniController,
                decoration: const InputDecoration(
                  hintText: 'Enter your DNI',
                  labelText: 'Enter your DNI',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _correoController,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ValueListenableBuilder<bool>(
                valueListenable: _isButtonEnabled,
                builder: (context, isEnabled, child) {
                  return Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isEnabled ? Theme.of(context).primaryColor : Colors.grey,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: MaterialButton(
                      onPressed: isEnabled && !context.read<AuthenticationProvider>().isLoading
                          ? () {
                        saveUserDataToFireStore();
                      }
                          : null,
                      child: context.watch<AuthenticationProvider>().isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.orangeAccent,
                      )
                          : const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // save user data to firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber!,
      image: '',
      token: '',
      aboutMe: 'Hey there, I\'m using Flutter Chat Pro',
      lastSeen: '',
      createdAt: '',
      isAdmin: false,
      isOnline: true,
      dni: _dniController.text.trim(),
      correo: _correoController.text.trim(),
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      fileImage: finalFileImage,
      onSuccess: () async {
        // save user data to shared preferences
        await authProvider.saveUserDataToSharedPreferences();

        navigateToHomeScreen();
      },
      onFail: () async {
        showSnackBar(context, 'Failed to save user data');
      },
    );
  }

  void navigateToHomeScreen() {
    // navigate to home screen and remove all previous screens
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
          (route) => false,
    );
  }
}