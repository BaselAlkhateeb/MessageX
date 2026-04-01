import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/Routes/app_routes.dart';
import 'package:messagex/controllers/auth_controller.dart';
import 'package:messagex/models/friend_request_model.dart';
import 'package:messagex/models/friendship_model.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

enum UserRelationShipStatus {
  none,
  friendRequestSent,
  friendRequestRecieved,
  friends,
  blocked,
}

class UsersListController extends GetxController {
  final FirestoreService firestoreService = FirestoreService();
  final AuthController authController = Get.find<AuthController>();
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;
  final Uuid _uuid = Uuid();

  final RxMap<String, UserRelationShipStatus> _userRelationShips =
      <String, UserRelationShipStatus>{}.obs;

  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<UserModel> _filteredUsers = <UserModel>[].obs;
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _recievedRequests =
      <FriendRequestModel>[].obs;
  final RxList<FriendshipModel> _friendShips = <FriendshipModel>[].obs;

  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;
  Map<String, UserRelationShipStatus> get userRelationShips =>
      _userRelationShips;
  String get searchQuery => _searchQuery.value;
  String get error => _error.value;

  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    loadUsers();
    loadRelationShips();
    debounce(
      _sentRequests,
      (_) => _filteredUsers(),
      time: const Duration(milliseconds: 300),
    );
      debounce(
      _searchQuery,
      (_) => filterUsers(),
      time: const Duration(milliseconds: 300),
    );
    super.onInit();
  }

  void loadUsers() async {
    _users.bindStream(firestoreService.getAllUsersStream());
    // filter out current user and update filtered List
    ever(_users, (List<UserModel> userList) {
      final currentUserId = authController.user?.uid;
      final otherUsers = userList
          .where((user) => user.id != currentUserId)
          .toList();
      if (_searchQuery.value.isEmpty) {
        _filteredUsers.value = otherUsers;
      } else {
        filterUsers();
      }
    });
  }

  void loadRelationShips() {
    final currentUserId = authController.user?.uid;
    if (currentUserId != null) {
      _sentRequests.bindStream(
        firestoreService.getSentFriendRequestsStream(currentUserId),
      );
      _recievedRequests.bindStream(
        firestoreService.getFriendRequestsStream(currentUserId),
      );
      _friendShips.bindStream(firestoreService.getFriendsStream(currentUserId));

      //update  relationship status whenever any of the lists change
      ever(_sentRequests, (_) => _updateUserRelationShips());
      ever(_recievedRequests, (_) => _updateUserRelationShips());
      ever(_friendShips, (_) => _updateUserRelationShips());
      ever(_users, (_) => _updateUserRelationShips());
    }
  }

  void _updateUserRelationShips() {
    final currentUserId = authController.user?.uid;
    if (currentUserId == null) return;
    for (var user in _users) {
      if (user.id != currentUserId) {
        final status = _calculateRelationshipStatus(user.id);
        _userRelationShips[user.id] = status;
      }
    }
  }

  UserRelationShipStatus _calculateRelationshipStatus(String userId) {
    final currentUserId = authController.user?.uid;
    if (currentUserId == null) return UserRelationShipStatus.none;

    // check if they are friends
    final friendShip = _friendShips.firstWhereOrNull(
      (friendship) =>
          (friendship.user1Id == currentUserId &&
              friendship.user2Id == userId) ||
          (friendship.user2Id == currentUserId && friendship.user1Id == userId),
    );
    if (friendShip != null) {
      if (friendShip.isBlocked) {
        return UserRelationShipStatus.blocked;
      } else {
        return UserRelationShipStatus.friends;
      }
    }
    // check if there is a sent friend request
    final sentRequest = _sentRequests.firstWhereOrNull(
      (request) =>
          request.status == FriendRequestStatus.pending &&
          request.receiverId == userId,
    );
    if (sentRequest != null) {
      return UserRelationShipStatus.friendRequestSent;
    }
    // check if there is a received friend request
    final recievedRequest = _recievedRequests.firstWhereOrNull(
      (request) =>
          request.status == FriendRequestStatus.pending &&
          request.senderId == userId,
    );
    if (recievedRequest != null) {
      return UserRelationShipStatus.friendRequestRecieved;
    }
    return UserRelationShipStatus.none;
  }

  void filterUsers() {
    final currentUserId = authController.user?.uid;
    final query = _searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      _filteredUsers.value = _users
          .where((user) => user.id != currentUserId)
          .toList();
    } else {
      _filteredUsers.value = _users.where((user) {
        return user.id != currentUserId &&
            (user.displayName.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query));
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> sendFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = authController.user?.uid;
      if (currentUserId != null) {
        final friendRequest = FriendRequestModel(
          id: _uuid.v4(),
          senderId: currentUserId,
          receiverId: user.id,

          createdAt: DateTime.now(),
        );

        _userRelationShips[user.id] = UserRelationShipStatus.friendRequestSent;

        await firestoreService.sendFriendRequest(friendRequest);
      }
      Get.snackbar('success', 'Friend Request Sent To ${user.displayName}');
    } catch (e) {
      _userRelationShips[user.id] = UserRelationShipStatus.none;
      _error.value = e.toString();
      print('Failed to send friend request: $e');
      Get.snackbar('Error', 'Failed to send friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = authController.user?.uid;
      if (currentUserId != null) {
        final sentRequest = _sentRequests.firstWhereOrNull(
          (request) =>
              request.status == FriendRequestStatus.pending &&
              request.receiverId == user.id,
        );
        if (sentRequest != null) {
          _userRelationShips[user.id] = UserRelationShipStatus.none;

          await firestoreService.cancelFriendRequest(sentRequest.id);
        }
      }
      Get.snackbar('success', 'Friend Request Cancelled');
    } catch (e) {
      _userRelationShips[user.id] = UserRelationShipStatus.friendRequestSent;
      _error.value = e.toString();
      print('Failed to cancel friend request: $e');
      Get.snackbar('Error', 'Failed to cancel friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> acceptFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = authController.user?.uid;
      if (currentUserId != null) {
        final recievedRequest = _recievedRequests.firstWhereOrNull(
          (request) =>
              request.status == FriendRequestStatus.pending &&
              request.senderId == user.id,
        );
        if (recievedRequest != null) {
          _userRelationShips[user.id] = UserRelationShipStatus.friends;

          await firestoreService.respondToFriendRequest(
            recievedRequest.id,
            FriendRequestStatus.accepted,
          );
        }
      }
      Get.snackbar('success', 'Friend Request Accepted');
    } catch (e) {
      _userRelationShips[user.id] =
          UserRelationShipStatus.friendRequestRecieved;
      _error.value = e.toString();
      print('Failed to accept friend request: $e');
      Get.snackbar('Error', 'Failed to accept friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> declineFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = authController.user?.uid;
      if (currentUserId != null) {
        final recievedRequest = _recievedRequests.firstWhereOrNull(
          (request) =>
              request.status == FriendRequestStatus.pending &&
              request.senderId == user.id,
        );
        if (recievedRequest != null) {
          _userRelationShips[user.id] = UserRelationShipStatus.none;

          await firestoreService.respondToFriendRequest(
            recievedRequest.id,
            FriendRequestStatus.declined,
          );
        }
      }
      Get.snackbar('success', 'Friend Request Declined');
    } catch (e) {
      _userRelationShips[user.id] =
          UserRelationShipStatus.friendRequestRecieved;
      _error.value = e.toString();
      print('Failed to decline friend request: $e');
      Get.snackbar('Error', 'Failed to decline friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = authController.user?.uid;
      if (currentUserId != null) {
        final relationship =
            _userRelationShips[user.id] ?? UserRelationShipStatus.none;
        if (relationship != UserRelationShipStatus.friends) {
          Get.snackbar(
            'Info',
            'You can only start a chat with friends. , please send a friend request first.',
          );
          return;
        }
        final chatId = await firestoreService.createOrGetChat(
          currentUserId,
          user.id,
        );

        Get.toNamed(
          AppRoutes.chat,
          arguments: {'chatId': chatId, 'otherUser': user},
        );
      }
    } catch (e) {
      _error.value = e.toString();
      print('Failed to start chat: $e');
      Get.snackbar('Error', 'Failed to start chat');
    } finally {
      _isLoading.value = false;
    }
  }

  UserRelationShipStatus getUserRelationshipStatus(String userId) {
    return _userRelationShips[userId] ?? UserRelationShipStatus.none;
  }

  String getRelationshipStatusButtonText(UserRelationShipStatus status) {
    switch (status) {
      case UserRelationShipStatus.none:
        return 'Add';
      case UserRelationShipStatus.friendRequestSent:
        return 'Request Sent';
      case UserRelationShipStatus.friendRequestRecieved:
        return 'Accept';
      case UserRelationShipStatus.friends:
        return 'Message';
      case UserRelationShipStatus.blocked:
        return 'Blocked';
    }
  }

  IconData getRelationshipStatusButtonIcon(UserRelationShipStatus status) {
    switch (status) {
      case UserRelationShipStatus.none:
        return Icons.person_add;
      case UserRelationShipStatus.friendRequestSent:
        return Icons.access_time;
      case UserRelationShipStatus.friendRequestRecieved:
        return Icons.check;
      case UserRelationShipStatus.friends:
        return Icons.chat_bubble_outline;
      case UserRelationShipStatus.blocked:
        return Icons.block;
    }
  }

  Color getRelationshipStatusButtonColor(UserRelationShipStatus status) {
    switch (status) {
      case UserRelationShipStatus.none:
        return Colors.blue;
      case UserRelationShipStatus.friendRequestSent:
        return Colors.orange;
      case UserRelationShipStatus.friendRequestRecieved:
        return Colors.green;
      case UserRelationShipStatus.friends:
        return Colors.blue;
      case UserRelationShipStatus.blocked:
        return Colors.redAccent;
    }
  }

  void handleRelationshipAction(UserModel user) {
    final status = getUserRelationshipStatus(user.id);
    switch (status) {
      case UserRelationShipStatus.none:
        sendFriendRequest(user);
        break;
      case UserRelationShipStatus.friendRequestSent:
        cancelFriendRequest(user);
        break;
      case UserRelationShipStatus.friendRequestRecieved:
        acceptFriendRequest(user);
        break;
      case UserRelationShipStatus.friends:
        startChat(user);
        break;
      case UserRelationShipStatus.blocked:
        Get.snackbar('Info', 'You have blocked this user.');
        break;
    }
  }

  String getLastSeenText(UserModel user) {
    if (user.isOnline) {
      return 'Online';
    } else {
      final duration = DateTime.now().difference(user.lastSeen);
      if (duration.inMinutes < 1) {
        return 'just now';
      } else if (duration.inHours < 1) {
        return 'Last seen ${duration.inMinutes} min ago';
      } else if (duration.inDays < 1) {
        return 'Last seen ${duration.inHours} hours ago';
      } else if (duration.inDays < 7) {
        return 'Last seen ${duration.inDays} days ago';
      } else {
        return 'Last seen on ${user.lastSeen.day}/${user.lastSeen.month}/${user.lastSeen.year}';
      }
    }
  }

  void clearError() {
    _error.value = '';
  }
}
