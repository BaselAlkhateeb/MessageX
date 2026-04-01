import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final AuthService authService = AuthService();
  final GlobalKey<FormState> myKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _emailSent = false.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get emailSent => _emailSent.value;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendPasswordResetEmail() async {
    if (!myKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;
      _error.value = '';

      await authService.sendRestPassword(emailController.text.trim());
      _emailSent.value = true;
      Get.snackbar(
        'Success',
        'Password reset email sent to ${emailController.text.trim()}',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: Duration(seconds: 4),
      );
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        duration: Duration(seconds: 4),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void gobackToLogin() {
    Get.back();
  }

  void resendEmail() {
    _emailSent.value = false;
    sendPasswordResetEmail();
  }

  String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'please enter a your email';
    }
    if (!GetUtils.isEmail(value!)) {
      return 'please enter a valid email';
    }
    return null;
  }

  void clearError(){
    _error.value = '';
  }
}
