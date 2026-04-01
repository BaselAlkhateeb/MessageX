import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/Routes/app_routes.dart';
import 'package:messagex/controllers/auth_controller.dart';
import 'package:messagex/models/friendship_model.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/services/firestore_service.dart';

class FriendsController extends GetxController {
  final firestoreService = FirestoreService();
  final authController = Get.find<AuthController>();
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<FriendshipModel> _friendShips = <FriendshipModel>[].obs;
  final RxList<UserModel> _friends = <UserModel>[].obs;
  final RxList<UserModel> _filteredFriends = <UserModel>[].obs;
  StreamSubscription? _friendshipsSubscription;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<UserModel> get friends => _friends;
  List<UserModel> get filteredFriends => _filteredFriends;
  List<FriendshipModel> get friendships => _friendShips;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    _loadFriends();
    debounce(
      _searchQuery,
      (_) => _filterFriends(),
      time: const Duration(milliseconds: 300),
    );
    super.onInit();
  }

  @override
  void onClose() {
    _friendshipsSubscription?.cancel();
  }

  void _loadFriends() {
    final currentUserId = authController.user?.uid;
    if (currentUserId != null) {
      _friendshipsSubscription?.cancel();

      _friendshipsSubscription = firestoreService
          .getFriendsStream(currentUserId)
          .listen((friendShipList) {
            _friendShips.value = friendShipList;
            _loadFriendsDetails(currentUserId, friendShipList);
          });
    }
  }

  Future<void> _loadFriendsDetails(
    String currentUserId,
    List<FriendshipModel> friendshipList,
  ) async {
    _isLoading.value = true;
    _error.value = '';
    try {
      List<UserModel> friendUsers = [];

      final futures = friendshipList.map((friendship) async {
        String friendId = friendship.getOtherUserId(currentUserId);
        return await firestoreService.getUser(friendId);
      }).toList();
      final results = await Future.wait(futures);
      for (var friend in results) {
        if (friend != null) {
          friendUsers.add(friend);
        }
        _friends.value = friendUsers;
        _filterFriends();
      }
    } catch (e) {
      _error.value = 'Failed to load friends: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void _filterFriends() {
    final query = _searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      _filteredFriends.value = List<UserModel>.from(_friends);
    } else {
      _filteredFriends.value = _friends
          .where(
            (friend) =>
                friend.displayName.toLowerCase().contains(query) ||
                friend.email.toLowerCase().contains(query),
          )
          .toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> refreshFriends() async {
    final currentUserId = authController.user?.uid;
    if (currentUserId != null) {
      _loadFriends();
    }
  }

  Future<void> removeFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Remove Friend'),
          content: Text(
            'Are you sure you want to remove ${friend.displayName} from your friends?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (result == true) {
        final currentUserId = authController.user?.uid;
        if (currentUserId != null) {
          await firestoreService.removeFriendship(currentUserId, friend.id);
          Get.snackbar(
            'Success',
            '${friend.displayName} has been removed from your friends.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove friend',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: const Duration(seconds: 4),
      );
      print(e.toString);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> blockFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Block User'),
          content: Text(
            'Are you sure you want to block ${friend.displayName}? You will no longer be able to see their profile or send them messages.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text('Block'),
            ),
          ],
        ),
      );
      if (result != true) return;

      final currentUserId = authController.user?.uid;
      if (currentUserId != null) {
        await firestoreService.blockUser(currentUserId, friend.id);
        await firestoreService.removeFriendship(currentUserId, friend.id);
        Get.snackbar(
          'Success',
          '${friend.displayName} has been blocked.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to block user',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: const Duration(seconds: 4),
      );
      print(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel friend) async {
    try {
      _isLoading.value = true;
      final currentUserId = authController.user?.uid;
      if (currentUserId != null) {
        String chatId = await firestoreService.createOrGetChat(
          currentUserId,
          friend.id,
        );
        Get.toNamed(AppRoutes.chat, arguments: {
          'chatId': chatId,
          'otherUser': friend,
          'isNewChat': true,

        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start chat',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: const Duration(seconds: 4),
      );
      print(e.toString());
    }finally {
      _isLoading.value = false;
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

  void openFriendRequests() {
    Get.toNamed(AppRoutes.friendRequests);
  }
  void clearError() {
    _error.value = '';
  }
}
