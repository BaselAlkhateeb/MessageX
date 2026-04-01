import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/auth_controller.dart';

class ChangePasswordController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> myKey = GlobalKey<FormState>();
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _obscureCurrentPassword = true.obs;
  final RxBool _obscureNewPassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  bool get obscureCurrentPassword => _obscureCurrentPassword.value;
  bool get obscureNewPassword => _obscureNewPassword.value;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    _obscureCurrentPassword.value = !_obscureCurrentPassword.value;
  }

  void toggleNewPasswordVisibility() {
    _obscureNewPassword.value = !_obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
  }

  Future<void> changePassword() async {
    if (!myKey.currentState!.validate()) return;
    try {
      _isLoading.value = true;
      _error.value = '';
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(' No User Logged In');
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPasswordController.text);
      Get.snackbar(
        'Success',
        'Password Changed Successfully}',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: Duration(seconds: 4),
      );
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
     await authController.signOut();
    } on FirebaseAuthException catch (e) {
      String errMessage;
      switch (e.code) {
        case 'wrong-password':
          errMessage = 'Current Password Is Incorrect';
          break;
        case 'weak-password':
          errMessage = 'New Password Is Too Weak';
          break;
        case 'requires-recent-login':
          errMessage = 'Please sign out and sign in again to change password';
          break;
        default:
          errMessage = 'Failed to change password';
      }
      _error.value = errMessage;

      Get.snackbar(
        'Error',
        errMessage,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = 'Failed to change password';
      print(e.toString());
      Get.snackbar(
        'Error',
        _error.value,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  String? validateCurrentPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'please enter a your current password';
    }
    return null;
  }

  
  String? validateNewPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'please enter a your new password';
    }
     if(value!.length<6){
      return 'password must be at least 6 characters';
    }
    if(value == currentPasswordController.text){
      return 'The new password must be different from the old one.';
    }
    return null;
  }

  
  String? validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'please confirm your new password';
    }
   if(value! != newPasswordController.text){
    return 'passwords doesn\'t match';
   }

    return null;
  }

    void clearError(){
    _error.value = '';
  }



}
