import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/change_password_controller.dart';
import 'package:messagex/themes/app_theme.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: controller.myKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security_rounded,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Update Your Password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter your current password and choose a new secure password',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondryColor,
                  ),
                ),

                SizedBox(height: 40),
                Obx(
                  () => TextFormField(
                    controller: controller.currentPasswordController,
                    obscureText: controller.obscureCurrentPassword,
                    validator: controller.validateCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      hintText: 'Enter your current password',
                      prefixIcon: Icon(Icons.lock),

                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.toggleCurrentPasswordVisibility();
                        },

                        icon: Icon(
                          controller.obscureCurrentPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Obx(
                  () => TextFormField(
                    controller: controller.newPasswordController,
                    obscureText: controller.obscureNewPassword,
                    validator: controller.validateNewPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      hintText: 'Enter your new password',
                      prefixIcon: Icon(Icons.lock),

                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.toggleNewPasswordVisibility();
                        },

                        icon: Icon(
                          controller.obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Obx(
                  () => TextFormField(
                    controller: controller.confirmPasswordController,
                    obscureText: controller.obscureConfirmPassword,
                    validator: controller.validateConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your new password',
                      prefixIcon: Icon(Icons.lock),

                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.toggleConfirmPasswordVisibility();
                        },

                        icon: Icon(
                          controller.obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),
                ),
                       SizedBox(height: 40),
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : controller.changePassword,
              icon: controller.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.security),
              label: controller.isLoading
                  ? Text('Updating...')
                  : Text('Update Password'),
            ),
          ),
        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
