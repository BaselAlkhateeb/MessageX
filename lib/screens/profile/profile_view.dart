import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/Routes/app_routes.dart';
import 'package:messagex/controllers/profile_controller.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/themes/app_theme.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back)),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isEditing
                  ? controller.toggleEditing
                  : controller.toggleEditing,
              child: Text(
                controller.isEditing ? 'cancel' : 'Edit',
                style: TextStyle(
                  color: controller.isEditing
                      ? AppTheme.errorColor
                      : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Obx(() {
        final user = controller.currentUser;
        if (user == null) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 2,
            ),
          );
        } else {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: AppTheme.primaryColor,
                            child: user.photoUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      user.photoUrl,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              buildDefaultAvatar(user),
                                    ),
                                  )
                                : buildDefaultAvatar(user),
                          ),
                          if (controller.isEditing)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Get.snackbar(
                                      'Info',
                                      'Photo Update Coming Soon',
                                    );
                                  },
                                  icon: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: user.isOnline
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.textSecondryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: user.isOnline
                                    ? AppTheme.successColor
                                    : AppTheme.textSecondryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              user.isOnline ? 'Online' : 'Offline',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: user.isOnline
                                        ? AppTheme.successColor
                                        : AppTheme.textSecondryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        controller.getJoinedData(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  Obx(
                    () => Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Information',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: controller.displayNameController,
                              enabled: controller.isEditing,
                              decoration: InputDecoration(
                                labelText: 'Display Name',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: controller.emailController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                helperText: 'Email can\'t be changed',
                              ),
                            ),

                            if (controller.isEditing) ...[
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading
                                      ? null
                                      : controller.updateProfile,
                                  child: controller.isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text('Save Changes'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.security,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text('Change Password'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () =>
                              Get.toNamed(AppRoutes.changePassword),
                        ),
                  
                        Divider(color: Colors.grey, height: 1),
                  
                        ListTile(
                          leading: Icon(
                            Icons.delete_forever,
                            color: AppTheme.errorColor,
                          ),
                          title: Text('Delete Account'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () =>
                              controller.deleteAccount()
                        ),
                  
                        Divider(color: Colors.grey, height: 1),
                  
                                 ListTile(
                          leading: Icon(
                            Icons.logout,
                            color: AppTheme.errorColor,
                          ),
                          title: Text('Sign Out'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () =>
                              controller.signOut()
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,) , 
                  Text('MessageX v1.0.0' , style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondryColor
                  ),)
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}
Widget buildDefaultAvatar(UserModel? user) {
    if (user == null) return Text('?');
    return Text(
      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
