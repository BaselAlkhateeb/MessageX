import 'package:flutter/material.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/screens/profile/profile_view.dart';
import 'package:messagex/themes/app_theme.dart';

class FriendListItem extends StatelessWidget {
  const FriendListItem({
    super.key,
    required this.friend,
    required this.lastSeenText,
    required this.onTap,
    required this.onRemove,
    required this.onBlock,
  });
  final UserModel friend;
  final String lastSeenText;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onBlock;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor,
                    child: friend.photoUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              friend.photoUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  buildDefaultAvatar(friend),
                            ),
                          )
                        : buildDefaultAvatar(friend),
                  ),
                  if (friend.isOnline) OnlineCircle(),
                ],
              ),
              SizedBox(width: 8),
              buildNameEmailLastTextColumn(context),
              MyPopMenuButton(onRemove: onRemove, onBlock: onBlock, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }

  Expanded buildNameEmailLastTextColumn(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            friend.displayName,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            friend.email,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondryColor),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(
            lastSeenText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: friend.isOnline
                  ? AppTheme.successColor
                  : AppTheme.textSecondryColor,
              fontWeight: friend.isOnline ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class MyPopMenuButton extends StatelessWidget {
  const MyPopMenuButton({
    super.key,
    required this.onRemove,
    required this.onBlock,
    required this.onTap,
  });

  final VoidCallback onRemove;
  final VoidCallback onBlock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) => [

        PopupMenuItem(
          value: 'Message',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Message'),
            leading: Icon(
              Icons.chat_bubble,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'Block',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Block'),
            leading: Icon(Icons.block, color: AppTheme.errorColor),
          ),
        ),
        PopupMenuItem(
          value: 'Remove',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Remove Friend'),
            leading: Icon(
              Icons.person_remove,
              color: AppTheme.errorColor,
            ),
          ),
        ),
      ],
    
      onSelected: (value) {
        if (value == 'Remove') {
          onRemove();
        } else if (value == 'Block') {
          onBlock();
        } else if (value == 'Message') {
          onTap();
        }
      },
    );
  }
}

class OnlineCircle extends StatelessWidget {
  const OnlineCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: AppTheme.successColor,
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }
}
