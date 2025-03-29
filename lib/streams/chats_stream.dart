import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/last_message_model.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/widgets/chat_widget.dart';
import 'package:provider/provider.dart';

class ChatsStream extends StatelessWidget {
  const ChatsStream({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LastMessageModel>>(
      stream: context.read<ChatProvider>().getChatsListStream(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          final chatsList = snapshot.data!;
          if (chatsList.isEmpty) {
            return const Center(
              child: Text('No chats yet'),
            );
          }
          return ListView.builder(
            itemCount: chatsList.length,
            itemBuilder: (context, index) {
              final chat = chatsList[index];

              return FutureBuilder<UserModel>(
                future: context.read<AuthenticationProvider>().getUserById(chat.contactUID),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return const Text('Error loading user');
                  }

                  final user = userSnapshot.data!;
                  if (!user.isAdmin) {
                    return Container();  // Ignorar usuarios que no son admin
                  }

                  return ChatWidget(
                    chat: chat,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: chat.contactUID,
                          Constants.contactName: chat.contactName,
                          Constants.contactImage: chat.contactImage,
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        }
        return const Center(
          child: Text('No chats yet'),
        );
      },
    );
  }
}