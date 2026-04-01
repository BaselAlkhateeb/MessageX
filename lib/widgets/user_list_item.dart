import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/users_list_controller.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/themes/app_theme.dart';

class UserListItem extends StatelessWidget {
  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
    required this.controller,
  });

  final UserModel user;
  final VoidCallback onTap;
  final UsersListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final relationShipStatus = controller.getUserRelationshipStatus(user.id);
      if (relationShipStatus == UserRelationShipStatus.friends) {
        return SizedBox.shrink();
      } else {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 28,
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                DisplayNameAndEmailColumn(user: user),
                Column(
                  children: [
                    buildActionButton(relationShipStatus),
                    if (relationShipStatus ==
                        UserRelationShipStatus.friendRequestRecieved) ...[
                      SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => controller.declineFriendRequest(user),
                        label: Text('Decline', style: TextStyle(fontSize: 10)),
                        icon: Icon(Icons.close_outlined, size: 14),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: BorderSide(color: AppTheme.errorColor),
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          minimumSize: Size(0, 24),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  Widget buildActionButton(UserRelationShipStatus status) {
    switch (status) {
      case UserRelationShipStatus.none:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          label: Text(controller.getRelationshipStatusButtonText(status)),
          icon: Icon(controller.getRelationshipStatusButtonIcon(status)),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.getRelationshipStatusButtonColor(
              status,
            ),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            minimumSize: Size(0, 32),
          ),
        );
      case UserRelationShipStatus.friendRequestSent:
        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: controller
                    .getRelationshipStatusButtonColor(status)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.getRelationshipStatusButtonColor(status),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.getRelationshipStatusButtonIcon(status),
                    color: controller.getRelationshipStatusButtonColor(status),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    controller.getRelationshipStatusButtonText(status),
                    style: TextStyle(
                      color: controller.getRelationshipStatusButtonColor(
                        status,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => showCancelRequestDialog(),
              label: Text('cancel', style: TextStyle(fontSize: 10)),
              icon: Icon(Icons.cancel_outlined, size: 14),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                side: BorderSide(color: Colors.redAccent),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                minimumSize: Size(0, 24),
              ),
            ),
          ],
        );

      case UserRelationShipStatus.friendRequestRecieved:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          label: Text(controller.getRelationshipStatusButtonText(status)),
          icon: Icon(controller.getRelationshipStatusButtonIcon(status)),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.getRelationshipStatusButtonColor(
              status,
            ),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            minimumSize: Size(0, 32),
          ),
        );
      case UserRelationShipStatus.blocked:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            border: Border.all(color: AppTheme.errorColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: AppTheme.errorColor, size: 16),
              SizedBox(width: 4),
              Text(
                'Blocked',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case UserRelationShipStatus.friends:
        return SizedBox.shrink();
    }
  }

  void showCancelRequestDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Friend Request'),
        content: Text(
          'Are you sure you want to cancel the friend request to ${user.displayName}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('No')),
          ElevatedButton(
            onPressed: () {
              controller.cancelFriendRequest(user);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class DisplayNameAndEmailColumn extends StatelessWidget {
  const DisplayNameAndEmailColumn({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondryColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
