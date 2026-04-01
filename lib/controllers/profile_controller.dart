import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/auth_controller.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/services/firestore_service.dart';

class ProfileController extends GetxController {
  final FirestoreService firestoreService = FirestoreService();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isEditing = false.obs;
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isEditing => _isEditing.value;
  UserModel? get currentUser => _currentUser.value;

  @override
  void onInit() {
    loadUserData();
    super.onInit();
  }

  @override
  void onClose() {
    // emailController.dispose();
    // displayNameController.dispose();
    super.onClose();
  }

  void loadUserData() {
    final currentUserId = authController.user?.uid;
    if (currentUserId != null) {
      _currentUser.bindStream(firestoreService.getUserStream(currentUserId));

      ever(_currentUser, (UserModel? user) {
        if (user != null) {
          displayNameController.text = user.displayName;
          emailController.text = user.email;
        }
      });
    }
  }

  void toggleEditing() {
    _isEditing.value = !_isEditing.value;
    if (!_isEditing.value) {
      final user = _currentUser.value;
      if (user != null) {
        displayNameController.text = user.displayName;
        emailController.text = user.email;
      }
    }
  }

  Future<void> updateProfile() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      final user = _currentUser.value;
      if (user == null) return;

      final updatedUser = user.copyWith(
        displayName: displayNameController.text,
      );
      await firestoreService.updateUser(updatedUser);
      _isEditing.value = false;
      Get.snackbar(
        'Success',
        'Profile Updated Successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = e.toString();
      print(e.toString());
      Get.snackbar(
        'Error',
        'Failed To Update Profile',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await authController.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Failed To Sign Out');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Delete Account'),
          content: Text(
            'Are you sure you want to delete your account ? this action can not be undone !!',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),

            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),

              child: Text('Delete'),
            ),
          ],
        ),
      );
      if (result == true) {
        _isLoading.value = true;
        await authController.deleteAccount();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed To Delete Account');
    } finally {
      _isLoading.value = false;
    }
  }

  String getJoinedData() {
    final user = _currentUser.value;
    if (user == null) return '';
    final data = user.createdAt;
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'joined at ${months[data.month - 1]} ${data.year}';
  }

  void clearError() {
    _error.value = '';
  }
}
