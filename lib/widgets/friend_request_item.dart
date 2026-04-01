import 'package:flutter/material.dart';
import 'package:messagex/models/friend_request_model.dart';
import 'package:messagex/models/user_model.dart';
import 'package:messagex/screens/profile/profile_view.dart';
import 'package:messagex/themes/app_theme.dart';
import 'package:messagex/widgets/friend_list_item.dart';

class FriendRequestItem extends StatelessWidget {
  const FriendRequestItem({
    super.key,
    required this.request,
    required this.user,
    required this.timeText,
    required this.isRecieved,
    this.onAccept,
    this.onDeclined,
    this.statusText,
    this.statusColor,
  });
  final FriendRequestModel request;
  final UserModel user;
  final String timeText;
  final bool isRecieved;
  final VoidCallback? onAccept;
  final VoidCallback? onDeclined;
  final String? statusText;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryColor,
                      child: user.photoUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                user.photoUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    buildDefaultAvatar(user),
                              ),
                            )
                          : buildDefaultAvatar(user),
                    ),
                    if (user.isOnline) OnlineCircle(),
                  ],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeText,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondryColor,
                          fontStyle: FontStyle.italic,
                        ),

                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isRecieved &&
                request.status == FriendRequestStatus.pending) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                      ),
                      label: Text('Accept'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onDeclined,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Decline'),
                    ),
                  ),
                ],
              ),
            ] else if (!isRecieved && statusText != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: statusColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor ?? AppTheme.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(request.status),
                      color: statusColor,
                      size: 16,
                    ),
                    SizedBox(width: 6,),
                    Text(statusText??'' , 
                    style: TextStyle(
                      fontWeight: FontWeight.w600
                    ),)
                  ]
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(FriendRequestStatus status){
switch(status){
  case FriendRequestStatus.pending:
  return Icons.hourglass_bottom;
    case FriendRequestStatus.accepted:
  return Icons.check_circle;
    case FriendRequestStatus.declined:
  return Icons.cancel;
}
  }
}
