import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/friends_request_controller.dart';
import 'package:messagex/themes/app_theme.dart';
import 'package:messagex/widgets/friend_request_item.dart';

class FriendRequestsView extends GetView<FriendsRequestController> {
  const FriendRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
        ),
      ),

      body: Column(
        children: [
          TabSelector(controller: controller),
          Expanded(
            child: Obx(() {
              return IndexedStack(
                index: controller.selectedTapIndex,

                children: [
                  _buildReceivedRequestsTap(),
                  _buildSentRequestsTap(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedRequestsTap() {
    return Obx(() {
      if (controller.recievedRequests.isEmpty) {
        return EmptyStatusWidget(
          icon: Icons.inbox_outlined,
          title: 'No Friend Requests',
          message:
              'When someone send you a friend request , it will appear here.',
        );
      } else {
        return ListView.separated(
          padding: EdgeInsets.all(16),

          separatorBuilder: (_, index) => SizedBox(height: 8),
          itemCount: controller.recievedRequests.length,

          itemBuilder: (_, index) {
            final request = controller.recievedRequests[index];
            final sender = controller.getUser(request.senderId);
            if (sender == null) {
              return SizedBox.shrink();
            } else {
              return FriendRequestItem(
                request: request,
                user: sender,
                timeText: controller.getRequestTimeText(request.createdAt),
                isRecieved: true,
                onAccept: () => controller.acceptRequest(request),
                onDeclined: () => controller.declineRequest(request),
              );
            }
          },
        );
      }
    });
  }

  Widget _buildSentRequestsTap() {
    return Obx(() {
      if (controller.sentRequests.isEmpty) {
        return EmptyStatusWidget(
          icon: Icons.inbox_outlined,
          title: 'No Requests sent',
          message: 'friend requests you send will appear here.',
        );
      } else {
        return ListView.separated(
          padding: EdgeInsets.all(16),

          separatorBuilder: (_, index) => SizedBox(height: 8),
          itemCount: controller.sentRequests.length,

          itemBuilder: (_, index) {
            final request = controller.sentRequests[index];
            final reciever = controller.getUser(request.receiverId);
            if (reciever == null) {
              return SizedBox.shrink();
            } else {
              return FriendRequestItem(
                request: request,
                user: reciever,
                timeText: controller.getRequestTimeText(request.createdAt),
                isRecieved: false,
                statusText: controller.getStatusText(request.status),
                statusColor: controller.getStatuscolor(request.status),
              );
            }
          },
        );
      }
    });
  }
}

class EmptyStatusWidget extends StatelessWidget {
  const EmptyStatusWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, size: 50, color: AppTheme.primaryColor),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TabSelector extends StatelessWidget {
  const TabSelector({super.key, required this.controller});

  final FriendsRequestController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTap(0),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: controller.selectedTapIndex == 0
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        color: controller.selectedTapIndex == 0
                            ? Colors.white
                            : AppTheme.textSecondryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Received(${controller.recievedRequests.length})',
                        style: TextStyle(
                          color: controller.selectedTapIndex == 0
                              ? Colors.white
                              : AppTheme.textSecondryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTap(1),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: controller.selectedTapIndex == 1
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send,
                        color: controller.selectedTapIndex == 1
                            ? Colors.white
                            : AppTheme.textSecondryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sent(${controller.sentRequests.length})',
                        style: TextStyle(
                          color: controller.selectedTapIndex == 1
                              ? Colors.white
                              : AppTheme.textSecondryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
