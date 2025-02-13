import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/enums/enums.dart';
import 'package:flutter_chat_pro/models/last_message_model.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/models/message_reply_model.dart';
import 'package:flutter_chat_pro/models/user_model.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;

  String _searchQuery = '';

  // getters
  String get searchQuery => _searchQuery;

  bool get isLoading => _isLoading;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  // firebase initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // send text message to firestore
  Future<void> sendTextMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required Function onSucess,
    required Function(String) onError,
  }) async {
    // set loading to true
    setLoading(true);
    try {
      var messageId = const Uuid().v4();

      // 1. check if its a message reply and add the replied message to the message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
          ? 'You'
          : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      // 2. update/set the messagemodel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: message,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
      );

      // 3. handle contact message
      await handleContactMessage(
        messageModel: messageModel,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        onSucess: onSucess,
        onError: onError,
      );

      // set message reply model to null
      setMessageReplyModel(null);
    } catch (e) {
      // set loading to true
      setLoading(false);
      onError(e.toString());
    }
  }

  Future<void> sendFileMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required File file,
    required MessageEnum messageType, // Asegúrate de pasar MessageEnum.file para archivos PDF
    required Function onSucess,
    required Function(String) onError,
  }) async {
    // set loading to true
    setLoading(true);
    try {
      var messageId = const Uuid().v4();

      // 1. check if it's a message reply and add the replied message to the message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
          ? 'You'
          : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      // 2. Verify the file type if needed (e.g., only allow PDFs)
      if (messageType == MessageEnum.file && !file.path.endsWith('.pdf')) {
        throw Exception("Only PDF files are allowed.");
      }

      // 3. upload file to Firebase Storage
      final ref =
          '${Constants.chatFiles}/${messageType.name}/${sender.uid}/$contactUID/$messageId';
      String fileUrl = await storeFileToStorage(file: file, reference: ref);

      // 4. update/set the MessageModel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: fileUrl,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
      );

      // handle contact message
      await handleContactMessage(
        messageModel: messageModel,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        onSucess: onSucess,
        onError: onError,
      );

      // Set message reply model to null
      setMessageReplyModel(null);

      // set loading to false
      setLoading(false);
      onSucess();
    } catch (e) {
      // set loading to false
      setLoading(false);
      onError(e.toString());
    }
  }

  Future<void> handleContactMessage({
    required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required Function onSucess,
    required Function(String p1) onError,
  }) async {
    try {
      // 0. contact messageModel
      final contactMessageModel = messageModel.copyWith(
        userId: messageModel.senderUID,
      );

      // 1. initialize last message for the sender
      final senderLastMessage = LastMessageModel(
        senderUID: messageModel.senderUID,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        message: messageModel.message,
        messageType: messageModel.messageType,
        timeSent: messageModel.timeSent,
        isSeen: false,
      );

      // 2. initialize last message for the contact
      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );
      // 3. send message to sender firestore location
      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageModel.messageId)
          .set(messageModel.toMap());
      // 4. send message to contact firestore location
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .collection(Constants.messages)
          .doc(messageModel.messageId)
          .set(contactMessageModel.toMap());

      // 5. send the last message to sender firestore location
      await _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .set(senderLastMessage.toMap());

      // 6. send the last message to contact firestore location
      await _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .set(contactLastMessage.toMap());

      // 7.call onSucess
      // set loading to false
      setLoading(false);
      onSucess();
    } on FirebaseException catch (e) {
      // set loading to false
      setLoading(false);
      onError(e.message ?? e.toString());
    } catch (e) {
      // set loading to false
      setLoading(false);
      onError(e.toString());
    }
  }

  // send reaction to message
  Future<void> sendReactionToMessage({
    required String senderUID,
    required String contactUID,
    required String messageId,
    required String reaction,
  }) async {
    // set loading to true
    setLoading(true);
    // a reaction is saved as senderUID=reaction
    String reactionToAdd = '$senderUID=$reaction';

    try {
      // handle contact message
      // 2. get the reaction list from firestore
      final messageData = await _firestore
          .collection(Constants.users)
          .doc(senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageId)
          .get();

      // 3. add the meesaage data to messageModel
      final message = MessageModel.fromMap(messageData.data()!);

      // 4. check if the reaction list is empty
      if (message.reactions.isEmpty) {
        // 5. add the reaction to the message
        await _firestore
            .collection(Constants.users)
            .doc(senderUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId)
            .update({
          Constants.reactions: FieldValue.arrayUnion([reactionToAdd])
        });
      } else {
        // 6. get UIDs list from reactions list
        final uids = message.reactions.map((e) => e.split('=')[0]).toList();

        // 7. check if the reaction is already added
        if (uids.contains(senderUID)) {
          // 8. get the index of the reaction
          final index = uids.indexOf(senderUID);
          // 9. replace the reaction
          message.reactions[index] = reactionToAdd;
        } else {
          // 10. add the reaction to the list
          message.reactions.add(reactionToAdd);
        }

        // 11. update the message to sender firestore location
        await _firestore
            .collection(Constants.users)
            .doc(senderUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId)
            .update({Constants.reactions: message.reactions});

        // 12. update the message to contact firestore location
        await _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(senderUID)
            .collection(Constants.messages)
            .doc(messageId)
            .update({Constants.reactions: message.reactions});
      }

      // set loading to false
      setLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }

  // get chatsList stream
  Stream<List<LastMessageModel>> getChatsListStream(String userId) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .orderBy(Constants.timeSent, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LastMessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  // stream messages from chat collection
  Stream<List<MessageModel>> getMessagesStream({
    required String userId,
    required String contactUID,
  }) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .doc(contactUID)
        .collection(Constants.messages)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  // stream the unread messages for this user
  Stream<int> getUnreadMessagesStream({
    required String userId,
    required String contactUID,
  }) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .doc(contactUID)
        .collection(Constants.messages)
        .where(Constants.isSeen, isEqualTo: false)
        .where(Constants.senderUID, isNotEqualTo: userId)
        .snapshots()
        .map((event) => event.docs.length);
  }

  // set message status
  Future<void> setMessageStatus({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required List<String> isSeenByList,
  }) async {
    // handle contact message
    // 2. update the current message as seen
    await _firestore
        .collection(Constants.users)
        .doc(currentUserId)
        .collection(Constants.chats)
        .doc(contactUID)
        .collection(Constants.messages)
        .doc(messageId)
        .update({Constants.isSeen: true});
    // 3. update the contact message as seen
    await _firestore
        .collection(Constants.users)
        .doc(contactUID)
        .collection(Constants.chats)
        .doc(currentUserId)
        .collection(Constants.messages)
        .doc(messageId)
        .update({Constants.isSeen: true});

    // 4. update the last message as seen for current user
    await _firestore
        .collection(Constants.users)
        .doc(currentUserId)
        .collection(Constants.chats)
        .doc(contactUID)
        .update({Constants.isSeen: true});

    // 5. update the last message as seen for contact
    await _firestore
        .collection(Constants.users)
        .doc(contactUID)
        .collection(Constants.chats)
        .doc(currentUserId)
        .update({Constants.isSeen: true});
  }

  // delete message
  Future<void> deleteMessage({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required String messageType,
    required bool deleteForEveryone,
  }) async {
    // set loading
    setLoading(true);

    // handle contact message
    // 1. update the current message as deleted
    await _firestore
        .collection(Constants.users)
        .doc(currentUserId)
        .collection(Constants.chats)
        .doc(contactUID)
        .collection(Constants.messages)
        .doc(messageId)
        .update({
      Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
    });
    // 2. check if delete for everyone then return if false
    if (!deleteForEveryone) {
      // set loading to false
      setLoading(false);
      return;
    }

    // 3. update the contact message as deleted
    await _firestore
        .collection(Constants.users)
        .doc(contactUID)
        .collection(Constants.chats)
        .doc(currentUserId)
        .collection(Constants.messages)
        .doc(messageId)
        .update({
      Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
    });

    // 4. delete the file from storage
    if (messageType != MessageEnum.text.name) {
      await deleteFileFromStorage(
        currentUserId: currentUserId,
        contactUID: contactUID,
        messageId: messageId,
        messageType: messageType,
      );
    }

    // set loading to false
    setLoading(false);
  }

  Future<void> deleteFileFromStorage({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required String messageType,
  }) async {
    final firebaseStorage = FirebaseStorage.instance;
    // delete the file from storage
    await firebaseStorage
        .ref(
        '${Constants.chatFiles}/$messageType/$currentUserId/$contactUID/$messageId')
        .delete();
  }

  // stream the last message collection
  Stream<QuerySnapshot> getLastMessageStream({
    required String userId,
  }) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .snapshots();
  }
}