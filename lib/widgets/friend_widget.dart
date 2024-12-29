import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:provider/provider.dart';

class FriendWidget extends StatelessWidget {
  const FriendWidget({
    super.key,
    required this.friend,
    required this.viewType,
    this.isAdminView = false,
    this.groupId = '',
  });

  final UserModel friend;
  final FriendViewType viewType;
  final bool isAdminView;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthenticationProvider>().userModel!.uid;
    final name = uid == friend.uid ? 'You' : friend.name;

    return ListTile(
      minLeadingWidth: 0.0,
      contentPadding: const EdgeInsets.only(left: -10),
      leading:
      userImageWidget(imageUrl: friend.image, radius: 40, onTap: () {}),
      title: Text(name),
      subtitle: Text(
        friend.aboutMe,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // Navegar a la pantalla de chat
        Navigator.pushNamed(context, Constants.chatScreen, arguments: {
          Constants.contactUID: friend.uid,
          Constants.contactName: friend.name,
          Constants.contactImage: friend.image,
          Constants.groupId: ''
        });
      },
    );
  }
}