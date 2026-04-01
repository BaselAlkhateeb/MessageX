import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/auth_controller.dart';
import 'package:messagex/controllers/home_controller.dart';
import 'package:messagex/models/chat_model.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/themes/app_theme.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    super.key,
    required this.chat,
    required this.otherUser,
    required this.lastMessageTime,
    required this.onTap,
  });

  final ChatModel chat;
  final UserModel otherUser;
  final String lastMessageTime;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final HomeController homeController = Get.find<HomeController>();
    final currentUserId = authController.user?.uid ?? '';
    final unreadCount = chat.getUnreadCount(currentUserId);

    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showChatOptions(context, homeController),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // قسم الصورة الشخصية وحالة الاتصال (من الصور 77, 99, 88)
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor,
                    child: otherUser.photoUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              otherUser.photoUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  otherUser.displayName.isNotEmpty
                                      ? otherUser.displayName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            otherUser.displayName.isNotEmpty
                                ? otherUser.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  if (otherUser.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16),
              // قسم النصوص والمعلومات (من الصور 10, 11, 12)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            otherUser.displayName,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMessageTime.isNotEmpty)
                          Text(
                            lastMessageTime,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: unreadCount > 0
                                      ? AppTheme.primaryColor
                                      : AppTheme.textSecondryColor,
                                  fontWeight: unreadCount > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (chat.lastMessageSenderId ==
                                  currentUserId) ...[
                                Icon(
                                  _getSeenStatusIcon(),
                                  size: 14,
                                  color: _getSeenStatusColor(),
                                ),
                                SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  chat.lastMessage ?? 'No messages yet',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: unreadCount > 0
                                            ? AppTheme.primaryColor
                                            : AppTheme.textSecondryColor,
                                        fontWeight: unreadCount > 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ), // Text
                              ), // Expanded
                            ],
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          SizedBox(width: 8),
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ), // EdgeInsets.symmetric
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ), // BoxDecoration
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ), // TextStyle
                            ), // Text
                          ), // Container
                        ],
                      ],
                    ),
                    if (chat.lastMessageSenderId == currentUserId) ...[
                      SizedBox(height: 2),
                      Text(
                        _getSeenStatusText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getSeenStatusColor(),
                          fontSize: 11,
                        ),
                      ), // Text
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSeenStatusIcon() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return Icons.done_all;
    } else {
      return Icons.done;
    }
  }

  Color _getSeenStatusColor() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return AppTheme.primaryColor;
    } else {
      return AppTheme.textSecondryColor;
    }
  }

  String _getSeenStatusText() {
    final AuthController authController = Get.find<AuthController>();
    final currentUserId = authController.user?.uid ?? '';
    final otherUserId = chat.getOtherParticipant(currentUserId);

    if (chat.isMessageSeen(currentUserId, otherUserId)) {
      return 'Seen';
    } else {
      return 'Delivered';
    }
  }

  void _showChatOptions(BuildContext context, HomeController homeController) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ), // BoxDecoration
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ), // BoxDecoration
            ), // Container
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppTheme.errorColor),
              title: Text('Delete Chat'),
              subtitle: Text('This will delete that chat for you only'),
              onTap: () {
                Get.back();
                homeController.deleteChat(chat);
              },
            ), // ListTile
            ListTile(
              leading: Icon(Icons.person_outline, color: AppTheme.primaryColor),
              title: Text('View Profile'),
              onTap: () {
                Get.back();
                // navigate to user profile, but i will not create profile screen,
                // you can create it if you want and navigate to it from here
              },
            ), // ListTile
            SizedBox(height: 10),
          ],
        ), // Column
      ), // Container
    );
  }
}
