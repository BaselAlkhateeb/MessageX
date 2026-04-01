import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/forgot_password_controller.dart';
import 'package:messagex/themes/app_theme.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});
  final controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.myKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Row(
                  children: [
                    IconButton(
                      onPressed: controller.gobackToLogin,
                      icon: Icon(Icons.arrow_back),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Forgot Password',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(fontSize: 24),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 56.0),
                  child: Text(
                    'Enter your email to recieve a password reset link',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondryColor,
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Obx(() {
                  if (controller.emailSent) {
                    return buildEmailSentContent();
                  } else {
                    return buildEmailForm();
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmailForm() {
    return Column(
      children: [
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email),
            hintText: 'Enter your email',
          ),
          validator: controller.validateEmail,
        ),
        SizedBox(height: 32),
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : controller.sendPasswordResetEmail,
              icon: controller.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.send),
              label: controller.isLoading
                  ? Text('Sinding...')
                  : Text('Send Reset Link'),
            ),
          ),
        ),
        SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remember your password ?',
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: controller.gobackToLogin,
              child: Text(
                'Sign in',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildEmailSentContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read_rounded,
                color: AppTheme.successColor,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Email Sent !',
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'we\'ve sent a password reset link to : ',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondryColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4),
              Text(
                controller.emailController.text,
                style: Theme.of(Get.context!).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),

              Text(
                'check your email and follow the instructions to reset your password',
                style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.resendEmail,
            icon: Icon(Icons.refresh),
            label: Text('Resend Email'),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.gobackToLogin,
            icon: Icon(Icons.arrow_back),
            label: Text('Back To Sign In'),
          ),
        ),
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppTheme.secondryColor),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Did\'t recieve the email? check your spam folder or try again',
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
