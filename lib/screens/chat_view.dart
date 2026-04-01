import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messagex/controllers/chat_controller.dart';
import 'package:messagex/themes/app_theme.dart';
import 'package:messagex/widgets/message_bubble.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  late final String chatId;
  late final ChatController controller;

  @override
  void initState() {
    super.initState();
    
    chatId = Get.arguments?['chatId'] ?? '';

    if (!Get.isRegistered<ChatController>(tag: chatId)) {
      Get.put<ChatController>(ChatController(), tag: chatId);
    }

    controller = Get.find<ChatController>(tag: chatId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }
              // هنا يتم عادةً وضع الـ ListView لعرض الرسائل
              return ListView.builder(
                reverse: true,
                controller: controller.scrollController,
                padding: EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMyMessage = controller.isMyMessage(message);

                  // حساب ما إذا كان يجب إظهار الوقت (إذا كانت أول رسالة أو فرق الوقت أكثر من 5 دقائق)
                  final showTime =
                      index == 0 ||
                      controller.messages[index - 1].timestamp
                              .difference(message.timestamp)
                              .inMinutes
                              .abs() >
                          5;

                  return MessageBubble(
                    message: message,
                    isMyMessage: isMyMessage,
                    showTime: showTime,
                    timeText: controller.formatMessageTime(message.timestamp),
                    onLongPress: isMyMessage
                        ? () => _showMessageOptions(message)
                        : null,
                  ); // MessageBubble
                },
              ); // ListView.builder
            }),
          ),
          _buildMessageInput() , // Expanded
        ], // children
      ), // Column
      // AppBar
    ); // Scaffold
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        controller.onChatResumed();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        controller.onChatPaused();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Get.delete<ChatController>(tag: chatId);
          Get.back();
        },
        icon: Icon(Icons.arrow_back),
      ), // IconButton
      title: Obx(() {
        final otherUser = controller.otherUser;
        if (otherUser == null) return Text('Chat');
        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor,
              child: otherUser.photoUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        otherUser.photoUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            otherUser.displayName.isNotEmpty
                                ? otherUser.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ), // TextStyle
                          ); // Text
                        },
                      ), // Image.network
                    ) // ClipOval
                  : Text(
                      otherUser.displayName.isNotEmpty
                          ? otherUser.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ), // TextStyle
                    ), // Text
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUser.displayName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ), // Text
                  Text(
                    otherUser.isOnline ? "Online" : 'Offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: otherUser.isOnline
                          ? AppTheme.successColor
                          : AppTheme.textSecondryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ), // Text
                ],
              ), // Column
            ), // Expanded// CircleAvatar
          ], // children
        ); // Row
      }),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                controller.deleteChat();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorColor,
                ), // Icon
                title: Text('Delete Chat'),
                contentPadding: EdgeInsets.zero,
              ), // ListTile
            ), // PopupMenuItem
          ],
        ), // PopupMenuButton
      ], // Obx
    );
  }

  Widget _buildEmptyState() {
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
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.chat_outlined,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ), // Container
            SizedBox(height: 16),
            Text(
              'Start the conversation',
              style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Send a message to get the chat started',
              style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ), // Column
      ), // Padding
    ); // Center
  }

  void _showMessageOptions(dynamic message) {
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
            ListTile(
              leading: Icon(Icons.edit, color: AppTheme.primaryColor), // Icon
              title: Text("Edit Message"),
              onTap: () {
                Get.back();
                _showEditDialog(message);
              },
            ), // ListTile
            ListTile(
              leading: Icon(Icons.delete, color: AppTheme.errorColor), // Icon
              title: Text("Delete Message"),
              onTap: () {
                Get.back();
                _showDeleteDialog(message);
              },
            ), // ListTile
          ],
        ), // Column
      ), // Container
    ); // Get.bottomSheet
  }

  void _showEditDialog(dynamic message) {
    final editController = TextEditingController(text: message.content);

    Get.dialog(
      AlertDialog(
        title: Text("Edit Message"),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(hintText: 'Enter new message'),
          maxLines: null,
        ), // TextField
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ), // TextButton
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty) {
                controller.editMessage(message, editController.text.trim());
                Get.back();
              }
            },
            child: Text("Save"),
          ), // TextButton
        ],
      ), // AlertDialog
    ); // Get.dialog
  }

  void _showDeleteDialog(dynamic message) {
    Get.dialog(
      AlertDialog(
        title: Text("Delete Message"),
        content: Text(
          "Are you sure you want to delete this message? This cannot be undone",
        ), // Text
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ), // TextButton
          TextButton(
            onPressed: () {
              controller.deleteMessage(message);
              Get.back();
            },
            child: Text("Delete", style: TextStyle(color: AppTheme.errorColor)),
          ), // TextButton
        ],
      ), // AlertDialog
    ); // Get.dialog
  }

  Widget _buildMessageInput() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(Get.context!).scaffoldBackgroundColor,
      border: Border(
        top: BorderSide(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ), // BorderSide
      ), // Border
    ), // BoxDecoration
    child: SafeArea(
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderColor),
              ), // BoxDecoration
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ), // EdgeInsets.symmetric
                      ), // InputDecoration
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => controller.sendMessage(),
                    ), // TextField
                  ), // Expanded
                ],
              ), // Row
            ), // Container
          ), // Expanded
          SizedBox(width: 8),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: controller.isTyping
                    ? AppTheme.primaryColor
                    : AppTheme.borderColor,
                borderRadius: BorderRadius.circular(24),
              ), // BoxDecoration
              child: IconButton(
                onPressed: controller.isSending
                    ? null
                    : controller.sendMessage,
                icon: Icon(
                  Icons.send_rounded,
                  color: controller.isTyping
                      ? Colors.white
                      : AppTheme.textSecondryColor,
                ), // Icon
              ), // IconButton
            ), // Container
          ), // Obx
        ],
      ), // Row
    ), // SafeArea
  ); // Container
}
}
