import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/models/message_reply_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/providers/group_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/align_message_left_widget.dart';
import 'package:flutter_chat_pro/widgets/align_message_right_widget.dart';
import 'package:flutter_chat_pro/widgets/message_widget.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.contactUID,
    required this.groupId,
  });

  final String contactUID;
  final String groupId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onContextMenuClicked(
      {required String item, required MessageModel message}) {
    switch (item) {
      case 'Reply':
        // set the message reply to true
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          messageType: message.messageType,
          isMe: true,
        );

        context.read<ChatProvider>().setMessageReplyModel(messageReply);
        break;
      case 'Copy':
        // copy message to clipboard
        Clipboard.setData(ClipboardData(text: message.message));
        showSnackBar(context, 'Message copied to clipboard');
        break;
      case 'Delete':
        final currentUserId =
            context.read<AuthenticationProvider>().userModel!.uid;
        final groupProvider = context.read<GroupProvider>();

        if (widget.groupId.isNotEmpty) {
          if (groupProvider.isSenderOrAdmin(
              message: message, uid: currentUserId)) {
            showDeletBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: true,
            );
            return;
          } else {
            showDeletBottomSheet(
              message: message,
              currentUserId: currentUserId,
              isSenderOrAdmin: false,
            );
            return;
          }
        }
        showDeletBottomSheet(
          message: message,
          currentUserId: currentUserId,
          isSenderOrAdmin: true,
        );
        break;
    }
  }

  void showDeletBottomSheet({
    required MessageModel message,
    required String currentUserId,
    required bool isSenderOrAdmin,
  }) {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (context) {
          return Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
            return SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 20.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chatProvider.isLoading) const LinearProgressIndicator(),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete for me'),
                      onTap: chatProvider.isLoading
                          ? null
                          : () async {
                              await chatProvider
                                  .deleteMessage(
                                currentUserId: currentUserId,
                                contactUID: widget.contactUID,
                                messageId: message.messageId,
                                messageType: message.messageType.name,
                                isGroupChat: widget.groupId.isNotEmpty,
                                deleteForEveryone: false,
                              )
                                  .whenComplete(() {
                                Navigator.pop(context);
                              });
                            },
                    ),
                    isSenderOrAdmin
                        ? ListTile(
                            leading: const Icon(Icons.delete_forever),
                            title: const Text('Delete for everyone'),
                            onTap: chatProvider.isLoading
                                ? null
                                : () async {
                                    await chatProvider
                                        .deleteMessage(
                                      currentUserId: currentUserId,
                                      contactUID: widget.contactUID,
                                      messageId: message.messageId,
                                      messageType: message.messageType.name,
                                      isGroupChat: widget.groupId.isNotEmpty,
                                      deleteForEveryone: true,
                                    )
                                        .whenComplete(() {
                                      Navigator.pop(context);
                                    });
                                  },
                          )
                        : const SizedBox.shrink(),
                    ListTile(
                      leading: const Icon(Icons.cancel),
                      title: const Text('cancel'),
                      onTap: chatProvider.isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void sendReactionToMessage(
      {required String reaction, required String messageId}) {
    // get the sender uid
    final senderUID = context.read<AuthenticationProvider>().userModel!.uid;

    context.read<ChatProvider>().sendReactionToMessage(
          senderUID: senderUID,
          contactUID: widget.contactUID,
          messageId: messageId,
          reaction: reaction,
          groupId: widget.groupId.isNotEmpty,
        );
  }

  void showEmojiContainer({required String messageId}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context);
            // add emoji to message
            sendReactionToMessage(
              reaction: emoji.emoji,
              messageId: messageId,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el UID del usuario actual
    final authProvider = context.read<AuthenticationProvider>();
    final uid = authProvider.userModel!.uid;


    return StreamBuilder<List<MessageModel>>(
      stream: context.read<ChatProvider>().getMessagesStream(
        userId: uid,
        contactUID: widget.contactUID,
        isGroup: widget.groupId,
      ),
      builder: (context, snapshot) {
        // Manejo de errores
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Something went wrong. Please try again later.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Mostrar indicador de carga mientras se espera la data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Manejar caso de datos nulos o lista vacía
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Start a conversation',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          );
        }

        // Obtener los mensajes desde el snapshot
        final messagesList = snapshot.data!;

        // Hacer scroll automático al nuevo mensaje
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          }
        });

        return GroupedListView<dynamic, DateTime>(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          reverse: true,
          controller: _scrollController,
          elements: messagesList,
          groupBy: (element) => DateTime(
            element.timeSent!.year,
            element.timeSent!.month,
            element.timeSent!.day,
          ),
          groupHeaderBuilder: (dynamic groupedByValue) => SizedBox(
            height: 40,
            child: buildDateTime(groupedByValue),
          ),
          itemBuilder: (context, dynamic element) {
            final message = element as MessageModel;

            // Si es un chat grupal, marcar mensajes como vistos automáticamente
            if (widget.groupId.isNotEmpty) {
              context.read<ChatProvider>().setMessageStatus(
                currentUserId: uid,
                contactUID: widget.contactUID,
                messageId: message.messageId,
                isSeenByList: message.isSeenBy,
                isGroupChat: true,
              );
            } else {
              // Marcar mensaje como visto si no es del remitente actual
              if (!message.isSeen && message.senderUID != uid) {
                context.read<ChatProvider>().setMessageStatus(
                  currentUserId: uid,
                  contactUID: widget.contactUID,
                  messageId: message.messageId,
                  isSeenByList: message.isSeenBy,
                  isGroupChat: false,
                );
              }
            }

            // Verificar si el mensaje fue eliminado por el usuario actual
            final isMe = element.senderUID == uid;
            final deletedByCurrentUser = message.deletedBy.contains(uid);

            // Ocultar mensajes eliminados
            if (deletedByCurrentUser) {
              return const SizedBox.shrink();
            }

            return GestureDetector(
              onLongPress: () async {
                Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (context) {
                      return ReactionsDialogWidget(
                        id: element.messageId,
                        messageWidget: isMe
                            ? AlignMessageRightWidget(
                          message: message,
                          viewOnly: true,
                          isGroupChat: widget.groupId.isNotEmpty,
                        )
                            : AlignMessageLeftWidget(
                          message: message,
                          viewOnly: true,
                          isGroupChat: widget.groupId.isNotEmpty,
                        ),
                        onReactionTap: (reaction) {
                          if (reaction == '➕') {
                            showEmojiContainer(messageId: element.messageId);
                          } else {
                            sendReactionToMessage(
                              reaction: reaction,
                              messageId: element.messageId,
                            );
                          }
                        },
                        onContextMenuTap: (item) {
                          onContextMenuClicked(
                            item: item.label,
                            message: message,
                          );
                        },
                        widgetAlignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                      );
                    },
                  ),
                );
              },
              child: Hero(
                tag: element.messageId,
                child: MessageWidget(
                  message: element,
                  onRightSwipe: () {
                    // Establecer el mensaje como respuesta
                    final messageReply = MessageReplyModel(
                      message: element.message,
                      senderUID: element.senderUID,
                      senderName: element.senderName,
                      senderImage: element.senderImage,
                      messageType: element.messageType,
                      isMe: isMe,
                    );

                    context
                        .read<ChatProvider>()
                        .setMessageReplyModel(messageReply);
                  },
                  isMe: isMe,
                  isGroupChat: widget.groupId.isNotEmpty,
                ),
              ),
            );
          },
          groupComparator: (value1, value2) => value2.compareTo(value1),
          itemComparator: (item1, item2) =>
              item2.timeSent!.compareTo(item1.timeSent!),
          useStickyGroupSeparators: true,
          floatingHeader: true,
          order: GroupedListOrder.ASC,
        );
      },
    );
  }
}
