import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/auth_controller.dart';
import 'package:messagex/models/friend_request_model.dart';
import 'package:messagex/models/friendship_model.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/services/firestore_service.dart';

class FriendsRequestController extends GetxController {
  final FirestoreService firestoreService = FirestoreService();
  final AuthController authController = Get.find<AuthController>();
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _recievedRequests =
      <FriendRequestModel>[].obs;
  final RxMap<String, UserModel> _users = <String, UserModel>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxInt _selectedTapIndex = 0.obs;

  List<FriendRequestModel> get sentRequests => _sentRequests;
  List<FriendRequestModel> get recievedRequests => _recievedRequests;
  Map<String, UserModel> get userRelationShips => _users;
  String get error => _error.value;
  bool get isLoading => _isLoading.value;
  int get selectedTapIndex => _selectedTapIndex.value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadFriendRequests();
    _loadUsers();
  }

  void _loadFriendRequests() {
    final currentUserId = authController.user?.uid;
    if (currentUserId != null) {
      _recievedRequests.bindStream(
        firestoreService.getFriendRequestsStream(currentUserId),
      );
      _sentRequests.bindStream(
        firestoreService.getSentFriendRequestsStream(currentUserId),
      );
    }
  }

  void _loadUsers() {
    _users.bindStream(
      firestoreService.getAllUsersStream().map((usersList) {
        Map<String, UserModel> usersMap = {};
        for (var user in usersList) {
          usersMap[user.id] = user;
        }
        return usersMap;
      }),
    );
  }

  void changeTap(int index) {
    _selectedTapIndex.value = index;
  }

  UserModel? getUser(String userId) {
    return _users[userId];
  }

  Future<void> acceptRequest(FriendRequestModel request) async {
    try {
      _isLoading.value = true;
      await firestoreService.respondToFriendRequest(
        request.id,
        FriendRequestStatus.accepted,
      );

      Get.snackbar('success', 'Friend Request Accepted');
    } catch (e) {
      _error.value = 'Failed to accept friend request';
      print(e.toString());
      Get.snackbar('Error', 'Failed to accept friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> declineRequest(FriendRequestModel request) async {
    try {
      _isLoading.value = true;
      await firestoreService.respondToFriendRequest(
        request.id,
        FriendRequestStatus.declined,
      );

      Get.snackbar('success', 'Friend Request Declined');
    } catch (e) {
      _error.value = 'Failed to decline friend request';
      print(e.toString());
      Get.snackbar('Error', 'Failed to decline friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      _isLoading.value = true;
      await firestoreService.unBlockUser(authController.user!.uid, userId);

      Get.snackbar('success', 'User Unblocked Successfully');
    } catch (e) {
      _error.value = 'Failed to unblock user';
      print(e.toString());
      Get.snackbar('Error', 'Failed to unblock');
    } finally {
      _isLoading.value = false;
    }
  }

  String getRequestTimeText(DateTime createdAt) {
    final duration = DateTime.now().difference(createdAt);
    if (duration.inMinutes < 1) {
      return 'just now';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes} min ago';
    } else if (duration.inDays < 1) {
      return '${duration.inHours} hours ago';
    } else if (duration.inDays < 7) {
      return '${duration.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String getStatusText(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return 'Pending';
      case FriendRequestStatus.accepted:
        return 'Accepted';
      case FriendRequestStatus.declined:
        return 'Declined';
    }
  }

  Color getStatuscolor(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return Colors.orange;
      case FriendRequestStatus.accepted:
        return Colors.green;
      case FriendRequestStatus.declined:
        return Colors.redAccent;
    }
  }
   void clearError() {
    _error.value = '';
  }
}
