import 'package:flutter_chat_pro/constants.dart';

class UserModel {
  String uid;
  String name;
  String phoneNumber;
  String image;
  String token;
  String aboutMe;
  String lastSeen;
  String createdAt;
  bool isAdmin;
  bool isOnline;
  String dni; // Nuevo atributo
  String correo; // Nuevo atributo

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.image,
    required this.token,
    required this.aboutMe,
    required this.lastSeen,
    required this.createdAt,
    required this.isAdmin,
    required this.isOnline,
    required this.dni, // Nuevo atributo
    required this.correo, // Nuevo atributo
  });

  // from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[Constants.uid] ?? '',
      name: map[Constants.name] ?? '',
      phoneNumber: map[Constants.phoneNumber] ?? '',
      image: map[Constants.image] ?? '',
      token: map[Constants.token] ?? '',
      aboutMe: map[Constants.aboutMe] ?? '',
      lastSeen: map[Constants.lastSeen] ?? '',
      createdAt: map[Constants.createdAt] ?? '',
      isAdmin: map[Constants.isAdmin] ?? false,
      isOnline: map[Constants.isOnline] ?? false,
      dni: map['dni'] ?? '', // Nuevo atributo
      correo: map['correo'] ?? '', // Nuevo atributo
    );
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.phoneNumber: phoneNumber,
      Constants.image: image,
      Constants.token: token,
      Constants.aboutMe: aboutMe,
      Constants.lastSeen: lastSeen,
      Constants.createdAt: createdAt,
      Constants.isAdmin: isAdmin,
      Constants.isOnline: isOnline,
      'dni': dni, // Nuevo atributo
      'correo': correo, // Nuevo atributo
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode {
    return uid.hashCode;
  }
}