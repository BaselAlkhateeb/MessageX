import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messagex/models/chat_model.dart';
import 'package:messagex/models/friend_request_model.dart';
import 'package:messagex/models/friendship_model.dart';
import 'package:messagex/models/message_model.dart';
import 'package:messagex/models/notification_model.dart';
import 'package:messagex/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel userModel) async {
    try {
      await firestore
          .collection('users')
          .doc(userModel.id)
          .set(userModel.toJson());
    } catch (e) {
      throw Exception('faild to create user : ${e.toString()}');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('faild to get user : ${e.toString()}');
    }
  }

  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        await firestore.collection('users').doc(userId).update({
          'isOnline': isOnline,
          'lastSeen': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('faild to update uer online status : ${e.toString()}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('faild to delete user: ${e.toString()}');
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('failed to update user');
    }
  }

  Stream<List<UserModel>> getAllUsersStream() {
    return firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> sendFriendRequest(FriendRequestModel request) async {
    try {
      await firestore
          .collection('friendRequests')
          .doc(request.id)
          .set(request.toJson());
      String notificationId =
          'friend_request_${request.senderId}_${request.receiverId}_${DateTime.now().millisecondsSinceEpoch}';

      await createNotification(
        NotificationModel(
          id: notificationId,
          userId: request.receiverId,
          title: 'New Friend Request',
          body:
              'You have recieved a new friend request from ${request.senderId}',
          type: NotificationType.friendRequest,
          data: {'senderId': request.senderId, 'requestId': request.id},
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('failed to send friend request: ${e.toString()}');
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try {
      DocumentSnapshot requestDoc = await firestore
          .collection('friendRequests')
          .doc(requestId)
          .get();
      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromJson(
          requestDoc.data() as Map<String, dynamic>,
        );
        await firestore.collection('friendRequests').doc(requestId).delete();

        await deleteNotificationByTypeAndUser(
          request.receiverId,
          NotificationType.friendRequest,
        );
      }
    } catch (e) {
      throw Exception('failed to cancel friend request: ${e.toString()}');
    }
  }

  Future<void> respondToFriendRequest(
    String requestId,
    FriendRequestStatus status,
  ) async {
    try {
      await firestore.collection('friendRequests').doc(requestId).update({
        'status': status.name,
        'respondedAt': DateTime.now().millisecondsSinceEpoch,
      });
      DocumentSnapshot requestDoc = await firestore
          .collection('friendRequests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        FriendRequestModel request = FriendRequestModel.fromJson(
          requestDoc.data() as Map<String, dynamic>,
        );

        if (status == FriendRequestStatus.accepted) {
          await createFriendShip(request.senderId, request.receiverId);

          await createNotification(
            NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: request.senderId,
              title: 'Friend Request Accepted',
              body: 'your friend request has been accepted.',
              type: NotificationType.friendRequestAccepted,
              data: {'userId': request.receiverId},
              createdAt: DateTime.now(),
            ),
          );

          await removeNotificationForCanceledRequest(
            request.receiverId,
            request.senderId,
          );
        } else if (status == FriendRequestStatus.declined) {
          await createNotification(
            NotificationModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: request.senderId,
              title: 'Friend Request Declined',
              body: 'your friend request has been declined.',
              type: NotificationType.friendRequestDiclined,
              data: {'userId': request.receiverId},
              createdAt: DateTime.now(),
            ),
          );

          await removeNotificationForCanceledRequest(
            request.receiverId,
            request.senderId,
          );
        }
      }
    } catch (e) {
      throw Exception('failed to respond to friend request: ${e.toString()}');
    }
  }

  Stream<List<FriendRequestModel>> getFriendRequestsStream(String userId) {
    return firestore
        .collection('friendRequests')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendRequestModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Stream<List<FriendRequestModel>> getSentFriendRequestsStream(String userId) {
    return firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FriendRequestModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<FriendRequestModel?> getFriendRequest(
    String senderId,
    String receiverId,
  ) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('friendRequests')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return FriendRequestModel.fromJson(
          snapshot.docs.first.data() as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('failed to get friend request: ${e.toString()}');
    }
  }

  Future<void> createFriendShip(String userId1, String userId2) async {
    try {
      List<String> userIds = [userId1, userId2];
      userIds.sort();
      String friendshipId = 'friendship_${userIds[0]}_${userIds[1]}';

      FriendshipModel friendship = FriendshipModel(
        id: friendshipId,
        user1Id: userIds[0],
        user2Id: userIds[1],
        createdAt: DateTime.now(),
      );
      await firestore
          .collection('friendships')
          .doc(friendshipId)
          .set(friendship.toJson());
    } catch (e) {
      throw Exception('failed to create friendship: ${e.toString()}');
    }
  }

  Future<void> removeFriendship(String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();
      String friendshipId = 'friendship_${userIds[0]}_${userIds[1]}';
      await firestore.collection('friendships').doc(friendshipId).delete();
      await createNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user2Id,
          title: 'Friend Removed',
          body: 'You have been removed from friends by $user1Id',
          type: NotificationType.friendRemoved,
          data: {'userId': user1Id},
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw Exception('failed to remove friendship: ${e.toString()}');
    }
  }

  Future<void> blockUser(String blockerId, String blockedId) async {
    try {
      List<String> userIds = [blockerId, blockedId];
      userIds.sort();
      String friendshipId = 'friendship_${userIds[0]}_${userIds[1]}';

      await firestore.collection('friendships').doc(friendshipId).update({
        'isBlocked': true,
        'blockedBy': blockerId,
      });
    } catch (e) {
      throw Exception('failed to block user: ${e.toString()}');
    }
  }

  Future<void> unBlockUser(String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();
      String friendshipId = 'friendship_${userIds[0]}_${userIds[1]}';

      await firestore.collection('friendships').doc(friendshipId).update({
        'isBlocked': false,
        'blockedBy': null,
      });
    } catch (e) {
      throw Exception('failed to unblock user: ${e.toString()}');
    }
  }

  Stream<List<FriendshipModel>> getFriendsStream(String userId) {
    return firestore
        .collection('friendships')
        .where('user1Id', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot1) async {
          QuerySnapshot snapshot2 = await firestore
              .collection('friendships')
              .where('user2Id', isEqualTo: userId)
              .get();
          List<FriendshipModel> friendships = [];
          for (var doc in snapshot1.docs) {
            friendships.add(FriendshipModel.fromJson(doc.data()));
          }
          for (var doc in snapshot2.docs) {
            friendships.add(
              FriendshipModel.fromJson(doc.data() as Map<String, dynamic>),
            );
          }
          return friendships.where((f) => !f.isBlocked).toList();
        });
  }

  Future<FriendshipModel?> getFriendShips(
    String user1Id,
    String user2Id,
  ) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();
      String friendshipId = 'friendship_${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await firestore
          .collection('friendships')
          .doc(friendshipId)
          .get();

      if (doc.exists) {
        return FriendshipModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('failed to get friendship: ${e.toString()}');
    }
  }

  Future<bool> isUserBlocked(String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();
      String friendshipId = 'friendship_${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await firestore
          .collection('friendships')
          .doc(friendshipId)
          .get();
      if (doc.exists) {
        FriendshipModel friendship = FriendshipModel.fromJson(
          doc.data() as Map<String, dynamic>,
        );
        return friendship.isBlocked;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('failed to check if user is blocked: ${e.toString()}');
    }
  }

  Future<bool> isUnFriend(String user1Id, String user2Id) async {
    try {
      List<String> userIds = [user1Id, user2Id];
      userIds.sort();
      String friendshipId = 'friendship_${userIds[0]}_${userIds[1]}';

      DocumentSnapshot doc = await firestore
          .collection('friendships')
          .doc(friendshipId)
          .get();

      return !doc.exists || (doc.exists && doc.data() == null);
    } catch (e) {
      throw Exception('failed to check if user is unfriend: ${e.toString()}');
    }
  }

  // chats collection

  Future<String> createOrGetChat(String user1Id, String user2Id) async {
    try {
      List<String> participants = [user1Id, user2Id];
      participants.sort();
      String chatId = 'chat_${participants[0]}_${participants[1]}';

      DocumentReference chatRef = firestore.collection('chats').doc(chatId);
      DocumentSnapshot chatDoc = await chatRef.get();
      if (!chatDoc.exists) {
        ChatModel newChat = ChatModel(
          id: chatDoc.id,
          participants: participants,
          unreadCount: {user1Id: 0, user2Id: 0},
          deletedBy: {user1Id: false, user2Id: false},
          deletedAt: {user1Id: null, user2Id: null},
          lastSeenBy: {user1Id: DateTime.now(), user2Id: DateTime.now()},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await chatRef.set(newChat.toJson());
      } else {
        ChatModel existingChat = ChatModel.fromJson(
          chatDoc.data() as Map<String, dynamic>,
        );
        if (existingChat.isDeletedBy(user1Id)) {
          await restoreChatForUsers(chatId, user1Id);
        }
        if (existingChat.isDeletedBy(user2Id)) {
          await restoreChatForUsers(chatId, user2Id);
        }
      }
      return chatId;
    } catch (e) {
      throw Exception('failed to create or get chat: ${e.toString()}');
    }
  }

  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromJson(doc.data()))
              .where((chat) => !chat.isDeletedBy(userId))
              .toList(),
        );
  }

  Future<void> updateChatLastMessage(
    String chatId,
    MessageModel message,
  ) async {
    try {
      await firestore.collection('chats').doc(chatId).update({
        'lastMessage': message.content,
        'lastMessageSenderId': message.senderId,
        'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('failed to update chat last message: ${e.toString()}');
    }
  }

  Future<void> updateUserLastSeen(String chatId, String userId) async {
    try {
      await firestore.collection('chats').doc(chatId).update({
        'lastSeenBy.$userId': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('failed to update user last seen: ${e.toString()}');
    }
  }

  Future<void> deleteChatForUser(String chatId, String userId) async {
    try {
      await firestore.collection('chats').doc(chatId).update({
        'deletedBy.$userId': true,
        'deletedAt.$userId': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('failed to delete chat for user: ${e.toString()}');
    }
  }

  Future<void> restoreChatForUsers(String chatId, String userId) async {
    try {
      await firestore.collection('chats').doc(chatId).update({
        'deletedBy.$userId': false,
      });
    } catch (e) {
      throw Exception('failed to restore chat for user: ${e.toString()}');
    }
  }

  Future<void> updateUnreadCount(
    String chatId,
    String userId,
    int count,
  ) async {
    try {
      await firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': count,
      });
    } catch (e) {
      throw Exception('failed to update unread count: ${e.toString()}');
    }
  }

  Future<void> restoreUnreadCount(String chatId, String userId) async {
    try {
      await firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      throw Exception('failed to restore unread count: ${e.toString()}');
    }
  }

  // Message collection
  // Future<void> sendMessage(MessageModel message) async {
  //   try {
  //     await firestore
  //         .collection('messages')
  //         .doc(message.id)
  //         .set(message.toJson());

  //     String chatId = await createOrGetChat(
  //       message.senderId,
  //       message.recieverId,
  //     );
  //     await updateChatLastMessage(chatId, message);
  //     await updateUserLastSeen(chatId, message.senderId);
  //     DocumentSnapshot chatDoc = await firestore
  //         .collection('chats')
  //         .doc(chatId)
  //         .get();
  //     if (chatDoc.exists) {
  //       ChatModel chat = ChatModel.fromJson(
  //         chatDoc.data() as Map<String, dynamic>,
  //       );
  //       int currentUnreadCount = chat.getUnreadCount(message.recieverId);
  //       await updateUnreadCount(
  //         chatId,
  //         message.recieverId,
  //         currentUnreadCount + 1,
  //       );
  //     }
  //   } catch (e) {
  //     throw Exception('failed to send message: ${e.toString()}');
  //   }
  // }

  Future<void> sendMessage(MessageModel message) async {
  try {
    await firestore
        .collection('messages')
        .doc(message.id)
        .set(message.toJson());

    String chatId = await createOrGetChat(
      message.senderId,
      message.recieverId,
    );

    await updateChatLastMessage(chatId, message);

    // 1️⃣ حدّث آخر ظهور للمرسِل
    await updateUserLastSeen(chatId, message.senderId);

    DocumentSnapshot chatDoc =
        await firestore.collection('chats').doc(chatId).get();

    if (chatDoc.exists) {
      ChatModel chat =
          ChatModel.fromJson(chatDoc.data() as Map<String, dynamic>);

      // 2️⃣ زِد unread للمستقبِل فقط
      int receiverUnread = chat.getUnreadCount(message.recieverId);
      await updateUnreadCount(
        chatId,
        message.recieverId,
        receiverUnread + 1,
      );

      // 3️⃣ صفّر unread للمرسِل (التعديل المهم)
      await updateUnreadCount(chatId, message.senderId, 0);
    }
  } catch (e) {
    throw Exception('failed to send message: ${e.toString()}');
  }
}


Future<void> markChatAsRead(String chatId, String currentUserId) async {
  await firestore.collection('chats').doc(chatId).update({
    'unreadCount.$currentUserId': 0,
    'lastSeenBy.$currentUserId': DateTime.now().millisecondsSinceEpoch,
  });
}


  Stream<List<MessageModel>> getMessagesStream(String user1Id, String user2Id) {
    return firestore
        .collection('messages')
        .where('senderId', whereIn: [user1Id, user2Id])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<String> participants = [user1Id, user2Id];
          participants.sort();
          String chatId = 'chat_${participants[0]}_${participants[1]}';
          DocumentSnapshot chatDoc = await firestore
              .collection('chats')
              .doc(chatId)
              .get();

          ChatModel? chat;
          if (chatDoc.exists) {
            chat = ChatModel.fromJson(chatDoc.data() as Map<String, dynamic>);
          }
          List<MessageModel> messages = [];
          for (var doc in snapshot.docs) {
            MessageModel message = MessageModel.fromJson(doc.data());
            if ((message.senderId == user1Id &&
                    message.recieverId == user2Id) ||
                (message.senderId == user2Id &&
                    message.recieverId == user1Id)) {
              bool includeMessage = true;
              if (chat != null) {
                DateTime? currenUserdeletedAt = chat.getDeletedAt(user1Id);
                if (currenUserdeletedAt != null &&
                    message.timestamp.isBefore(currenUserdeletedAt)) {
                  includeMessage = false;
                }
              }
              if (includeMessage) {
                messages.add(message);
              }
            }
          }
          messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return messages;
        });
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await firestore.collection('messages').doc(messageId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('failed to mark message as read: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await firestore.collection('messages').doc(messageId).delete();
    } catch (e) {
      throw Exception('failed to delete message: ${e.toString()}');
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await firestore.collection('messages').doc(messageId).update({
        'content': newContent,
        'isEdited': true,
        'editedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('failed to edit message: ${e.toString()}');
    }
  }

  // Notification collection
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      throw Exception('failed to create notification: ${e.toString()}');
    }
  }

  Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
    return firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('failed to mark notification as read: ${e.toString()}');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = firestore.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception(
        'failed to mark all notifications as read: ${e.toString()}',
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('failed to delete notification: ${e.toString()}');
    }
  }

  Future<void> deleteNotificationByTypeAndUser(
    String relatedUserId,
    NotificationType type,
  ) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('notifications')
          .where('userId', isEqualTo: relatedUserId)
          .where('type', isEqualTo: type.name)
          .get();

      WriteBatch batch = firestore.batch();
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['data'] != null &&
            (data['data']['senderId'] == relatedUserId ||
                data['data']['userId'] == relatedUserId)) {
          batch.delete(doc.reference);
        }
      }
      await batch.commit();
    } catch (e) {
      throw Exception('failed to delete notification: ${e.toString()}');
    }
  }

  Future<void> removeNotificationForCanceledRequest(
    String receiverId,
    String senderId,
  ) async {
    try {
      await deleteNotificationByTypeAndUser(
        receiverId,
        NotificationType.friendRequest,
      );
    } catch (e) {
      throw Exception('failed to remove notification: ${e.toString()}');
    }
  }
}
