import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/last_message_model.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/widgets/chat_widget.dart';
import 'package:provider/provider.dart';

class SearchStream extends StatelessWidget {
  const SearchStream({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: ((context, chatProvider, child) {
      return StreamBuilder<QuerySnapshot>(
          stream: chatProvider.getLastMessageStream(userId: uid),
          builder: (builderContext, snapshot) {
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

            final results = snapshot.data!.docs.where((element) =>
                element[Constants.contactName]
                    .toString()
                    .toLowerCase()
                    .contains(chatProvider.searchQuery.toLowerCase()));

            if (results.isEmpty) {
              return const Center(
                child: Text('No chats found'),
              );
            }

            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final chat = LastMessageModel.fromMap(
                      results.elementAt(index).data() as Map<String, dynamic>);
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
            }
            return const Center(
              child: Text('No chats found'),
            );
          });
    }));
  }
}